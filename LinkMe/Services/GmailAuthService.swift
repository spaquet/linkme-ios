import Foundation
import AuthenticationServices

/// Drives the Gmail OAuth 2.0 authorization flow using ASWebAuthenticationSession.
@MainActor
final class GmailAuthService: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = GmailAuthService()

    private var authSession: ASWebAuthenticationSession?

    private override init() {}

    /// Launch OAuth flow. Stores tokens on success.
    ///
    /// - Throws: `OAuthError` or `GmailAPIError` on failure.
    func authenticate() async throws {
        guard let authURL = GmailOAuthConfig.buildAuthURL() else {
            throw OAuthError.missingClientId
        }

        let callbackScheme = "com.stephanepaquet.linkme"
        let code = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        cont.resume(throwing: OAuthError.authCancelled)
                    } else {
                        cont.resume(throwing: error)
                    }
                    return
                }
                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                else {
                    let msg = callbackURL?.absoluteString ?? "nil"
                    cont.resume(throwing: OAuthError.invalidCallback(msg))
                    return
                }
                cont.resume(returning: code)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }

        try await exchangeCodeForTokens(code: code)
        try await fetchAndStoreEmail()
    }

    // MARK: - Token Exchange

    private func exchangeCodeForTokens(code: String) async throws {
        guard let clientId = GmailOAuthConfig.clientId else {
            throw OAuthError.missingClientId
        }

        var req = URLRequest(url: URL(string: GmailOAuthConfig.tokenURL)!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = [
            "code": code,
            "client_id": clientId,
            "redirect_uri": GmailOAuthConfig.redirectUri,
            "grant_type": "authorization_code"
        ]
        req.httpBody = params
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw GmailAPIError.httpError(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        struct TokenResponse: Decodable {
            let access_token: String
            let refresh_token: String?
            let expires_in: Int
        }
        let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
        OAuthTokenManager.shared.storeGmailTokens(
            accessToken: tokens.access_token,
            refreshToken: tokens.refresh_token,
            expiresIn: tokens.expires_in
        )
    }

    private func fetchAndStoreEmail() async throws {
        let token = try await OAuthTokenManager.shared.validGmailAccessToken()
        var req = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        struct UserInfo: Decodable { let email: String }
        if let info = try? JSONDecoder().decode(UserInfo.self, from: data) {
            OAuthTokenManager.shared.gmailEmail = info.email
        }
    }

    // MARK: - ASWebAuthenticationPresentationContextProviding

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

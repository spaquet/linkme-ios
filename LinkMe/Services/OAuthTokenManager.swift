import Foundation
import Security

/// Persists and refreshes OAuth tokens in the system Keychain.
@Observable
@MainActor
final class OAuthTokenManager {
    static let shared = OAuthTokenManager()

    /// Whether a valid Gmail access token is stored.
    var isGmailConnected: Bool { keychainLoad(key: KeychainKey.gmailAccessToken) != nil }

    /// Email address of the connected Gmail account, if any.
    var gmailEmail: String? {
        get { UserDefaults.standard.string(forKey: "gmail_connected_email") }
        set { UserDefaults.standard.set(newValue, forKey: "gmail_connected_email") }
    }

    private enum KeychainKey {
        static let gmailAccessToken = "com.stephanepaquet.LinkMe.gmail.accessToken"
        static let gmailRefreshToken = "com.stephanepaquet.LinkMe.gmail.refreshToken"
        static let gmailTokenExpiry = "com.stephanepaquet.LinkMe.gmail.tokenExpiry"
    }

    private init() {}

    // MARK: - Access Token

    /// Returns a valid Gmail access token, refreshing if needed.
    func validGmailAccessToken() async throws -> String {
        if let expiry = expiryDate(), Date() < expiry.addingTimeInterval(-60),
           let token = keychainLoad(key: KeychainKey.gmailAccessToken) {
            return token
        }
        return try await refreshGmailToken()
    }

    func storeGmailTokens(accessToken: String, refreshToken: String?, expiresIn: Int) {
        keychainSave(key: KeychainKey.gmailAccessToken, value: accessToken)
        if let rt = refreshToken {
            keychainSave(key: KeychainKey.gmailRefreshToken, value: rt)
        }
        let expiry = Date().addingTimeInterval(TimeInterval(expiresIn))
        UserDefaults.standard.set(expiry, forKey: KeychainKey.gmailTokenExpiry)
    }

    func disconnectGmail() {
        keychainDelete(key: KeychainKey.gmailAccessToken)
        keychainDelete(key: KeychainKey.gmailRefreshToken)
        UserDefaults.standard.removeObject(forKey: KeychainKey.gmailTokenExpiry)
        gmailEmail = nil
    }

    // MARK: - Refresh

    private func refreshGmailToken() async throws -> String {
        guard let refreshToken = keychainLoad(key: KeychainKey.gmailRefreshToken) else {
            throw OAuthError.noRefreshToken
        }
        guard let clientId = GmailOAuthConfig.clientId else {
            throw OAuthError.missingClientId
        }

        var req = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "client_id=\(clientId)&refresh_token=\(refreshToken)&grant_type=refresh_token"
        req.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: req)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)

        storeGmailTokens(
            accessToken: response.access_token,
            refreshToken: response.refresh_token,
            expiresIn: response.expires_in ?? 3600
        )
        return response.access_token
    }

    // MARK: - Keychain Helpers

    private func keychainSave(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func keychainLoad(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func keychainDelete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func expiryDate() -> Date? {
        UserDefaults.standard.object(forKey: KeychainKey.gmailTokenExpiry) as? Date
    }
}

/// Decoded OAuth token endpoint response.
private struct TokenResponse: Decodable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int?
}

enum OAuthError: LocalizedError {
    case noRefreshToken
    case missingClientId
    case authCancelled
    case invalidCallback(String)

    var errorDescription: String? {
        switch self {
        case .noRefreshToken: return "No refresh token — please reconnect Gmail."
        case .missingClientId: return "Gmail client ID not configured."
        case .authCancelled: return "Authentication cancelled."
        case .invalidCallback(let msg): return "OAuth callback error: \(msg)"
        }
    }
}

import Foundation

/// Gmail OAuth 2.0 configuration.
///
/// - Important: Set `GMAIL_CLIENT_ID` in your Xcode scheme environment variables,
///   or hardcode `clientId` for local development only (never commit secrets).
enum GmailOAuthConfig {
    /// OAuth client ID from Google Cloud Console (iOS app type).
    static var clientId: String? {
        // Read from environment first (CI / secure config)
        if let env = ProcessInfo.processInfo.environment["GMAIL_CLIENT_ID"], !env.isEmpty {
            return env
        }
        // Fallback: plist key (set GmailClientId in Info.plist)
        if let plist = Bundle.main.infoDictionary,
           let id = plist["GmailClientId"] as? String,
           !id.isEmpty, !id.hasPrefix("$(") {
            return id
        }
        return nil
    }

    /// Scopes — read-only Gmail access only.
    static let scopes = "https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/userinfo.email"

    /// Redirect URI — must match URL scheme registered in Info.plist.
    static let redirectUri = "com.stephanepaquet.linkme:/oauth2redirect"

    /// Google authorization endpoint.
    static let authorizationURL = "https://accounts.google.com/o/oauth2/v2/auth"

    /// Google token endpoint.
    static let tokenURL = "https://oauth2.googleapis.com/token"

    /// Builds the authorization URL for ASWebAuthenticationSession.
    static func buildAuthURL() -> URL? {
        guard let clientId else { return nil }
        var components = URLComponents(string: authorizationURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]
        return components.url
    }
}

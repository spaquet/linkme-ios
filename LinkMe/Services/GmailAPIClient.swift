import Foundation

/// Fetches messages from the Gmail REST API.
final class GmailAPIClient {
    static let shared = GmailAPIClient()

    private let baseURL = "https://gmail.googleapis.com/gmail/v1/users/me"
    private let maxMessages = 50

    private init() {}

    /// Fetch recent LinkedIn invitation emails.
    ///
    /// - Returns: Array of `EmailMessageModel` with full HTML body decoded.
    func fetchLinkedInEmails() async throws -> [EmailMessageModel] {
        let token = try await OAuthTokenManager.shared.validGmailAccessToken()

        // Query Gmail for LinkedIn invitation emails
        let query = "from:invitations@linkedin.com OR from:messages-noreply@linkedin.com"
        let ids = try await listMessages(token: token, query: query)

        var emails: [EmailMessageModel] = []
        for id in ids.prefix(maxMessages) {
            if let email = try? await fetchMessage(id: id, token: token) {
                emails.append(email)
            }
        }
        return emails
    }

    // MARK: - List

    private func listMessages(token: String, query: String) async throws -> [String] {
        var components = URLComponents(string: "\(baseURL)/messages")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "\(maxMessages)")
        ]

        var req = URLRequest(url: components.url!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        try checkHTTP(response, data: data)

        struct ListResponse: Decodable {
            struct Message: Decodable { let id: String }
            let messages: [Message]?
        }
        let list = try JSONDecoder().decode(ListResponse.self, from: data)
        return list.messages?.map(\.id) ?? []
    }

    // MARK: - Fetch Single

    private func fetchMessage(id: String, token: String) async throws -> EmailMessageModel {
        var components = URLComponents(string: "\(baseURL)/messages/\(id)")!
        components.queryItems = [URLQueryItem(name: "format", value: "full")]

        var req = URLRequest(url: components.url!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        try checkHTTP(response, data: data)

        let raw = try JSONDecoder().decode(GmailMessage.self, from: data)
        return try buildEmailModel(raw: raw)
    }

    // MARK: - Parsing

    private func buildEmailModel(raw: GmailMessage) throws -> EmailMessageModel {
        let headers = raw.payload?.headers ?? []
        func header(_ name: String) -> String? {
            headers.first { $0.name.lowercased() == name.lowercased() }?.value
        }

        let messageId = header("Message-Id") ?? raw.id
        let from = header("From") ?? ""
        let subject = header("Subject") ?? ""
        let dateStr = header("Date") ?? ""
        let timestamp = parseDate(dateStr) ?? Date(timeIntervalSince1970: TimeInterval((raw.internalDate ?? "0"))! / 1000)

        let (plainBody, htmlBody) = extractBodies(payload: raw.payload)

        return EmailMessageModel(
            id: messageId,
            gmailMessageId: raw.id,
            from: from,
            subject: subject,
            body: plainBody ?? "",
            htmlBody: htmlBody,
            timestamp: timestamp,
            provider: .gmail
        )
    }

    private func extractBodies(payload: GmailMessage.Payload?) -> (plain: String?, html: String?) {
        guard let payload else { return (nil, nil) }

        // Single-part message
        if let mimeType = payload.mimeType {
            if mimeType == "text/plain", let body = decodeBody(payload.body) {
                return (body, nil)
            }
            if mimeType == "text/html", let body = decodeBody(payload.body) {
                return (nil, body)
            }
        }

        // Multi-part: search parts recursively
        var plain: String?
        var html: String?
        for part in payload.parts ?? [] {
            let (p, h) = extractBodies(payload: GmailMessage.Payload(
                mimeType: part.mimeType,
                headers: part.headers,
                body: part.body,
                parts: part.parts
            ))
            if plain == nil { plain = p }
            if html == nil { html = h }
        }
        return (plain, html)
    }

    private func decodeBody(_ body: GmailMessage.Body?) -> String? {
        guard let data = body?.data, !data.isEmpty else { return nil }
        // Gmail uses URL-safe base64
        var base64 = data.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let decoded = Data(base64Encoded: base64) else { return nil }
        return String(data: decoded, encoding: .utf8)
    }

    private func parseDate(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["EEE, dd MMM yyyy HH:mm:ss Z", "dd MMM yyyy HH:mm:ss Z"] {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: str) { return date }
        }
        return nil
    }

    private func checkHTTP(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 401 { throw GmailAPIError.unauthorized }
        if http.statusCode == 429 { throw GmailAPIError.rateLimited }
        if http.statusCode >= 400 {
            throw GmailAPIError.httpError(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
    }
}

// MARK: - Gmail API Models

private struct GmailMessage: Decodable {
    let id: String
    let internalDate: String?
    let payload: Payload?

    struct Payload: Decodable {
        let mimeType: String?
        let headers: [Header]?
        let body: Body?
        let parts: [Part]?
    }

    struct Header: Decodable {
        let name: String
        let value: String
    }

    struct Body: Decodable {
        let data: String?
        let size: Int?
    }

    struct Part: Decodable {
        let mimeType: String?
        let headers: [Header]?
        let body: Body?
        let parts: [Part]?
    }
}

enum GmailAPIError: LocalizedError {
    case unauthorized
    case rateLimited
    case httpError(Int, String)

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Gmail token expired. Please reconnect."
        case .rateLimited: return "Gmail rate limit hit. Try again shortly."
        case .httpError(let code, let msg): return "Gmail API error \(code): \(msg)"
        }
    }
}

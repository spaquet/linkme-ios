import Foundation

/// Parses LinkedIn invitation acceptance emails.
///
/// Detects emails from invitations@linkedin.com and extracts structured
/// connection data (name, headline, profile URL, avatar) from HTML body.
final class LinkedInParser {

    /// Parse a LinkedIn invitation email.
    ///
    /// - Parameters:
    ///   - email: The email to parse.
    ///
    /// - Returns: Extracted connection, or nil if not a LinkedIn invitation or parsing fails.
    static func parse(_ email: EmailMessageModel) -> LinkedInConnection? {
        guard isLinkedInInvitation(email) else { return nil }

        let html = email.htmlBody ?? email.body
        guard !html.isEmpty else { return nil }

        guard let name = extractName(html), !name.isEmpty else { return nil }
        guard let profileUrl = extractProfileUrl(html), !profileUrl.isEmpty else { return nil }

        return LinkedInConnection(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            profileUrl: profileUrl,
            headline: extractHeadline(html),
            avatarUrl: extractAvatarUrl(html),
            extractedAt: email.timestamp,
            emailSubject: email.subject
        )
    }

    // MARK: - Detection

    /// Returns true if this email is a LinkedIn invitation acceptance.
    static func isLinkedInInvitation(_ email: EmailMessageModel) -> Bool {
        guard email.from.lowercased().contains("invitations@linkedin.com") else { return false }
        let subject = email.subject.lowercased()
        return subject.contains("accepted your invitation") ||
               subject.contains("now follow each other")
    }

    // MARK: - Extraction

    /// Extract clean LinkedIn profile URL (strip tracking params).
    static func extractProfileUrl(_ html: String) -> String? {
        let pattern = #"href="(https://www\.linkedin\.com/comm/in/[^"?]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }

        let commUrl = String(html[range])
        // Convert /comm/in/ → /in/ (canonical form)
        return commUrl.replacingOccurrences(of: "/comm/in/", with: "/in/")
    }

    /// Extract full name from profile image alt text.
    static func extractName(_ html: String) -> String? {
        let pattern = #"alt="([^"]+)'s Profile Picture""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }

        return String(html[range])
    }

    /// Extract headline (job title + company) from email body.
    static func extractHeadline(_ html: String) -> String? {
        let pattern = #"font-size:14px[^>]*>\s*([^<\n]{3,120})\s*<"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }

        let headline = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard headline.count > 3, !headline.hasPrefix("<") else { return nil }
        return headline
    }

    /// Extract avatar image URL (Google-proxied LinkedIn image).
    static func extractAvatarUrl(_ html: String) -> String? {
        let pattern = #"<img[^>]*src="([^"]+)"[^>]*alt="[^"]*Profile Picture""#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }

        return String(html[range])
    }
}

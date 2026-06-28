import Foundation

/// A LinkedIn connection detected from an invitation acceptance email.
///
/// Extracted from emails sent by invitations@linkedin.com when a connection
/// accepts a request. Stored until user claims or dismisses.
struct LinkedInConnection: Identifiable {
    /// Unique ID derived from LinkedIn profile URL.
    let id: String

    /// Full name of the connection.
    let name: String

    /// Clean LinkedIn profile URL (tracking params stripped).
    let profileUrl: String

    /// Headline from their LinkedIn profile (e.g., "Equity Analyst at Matisa Capital").
    let headline: String?

    /// Avatar image URL from email (Google-cached version).
    let avatarUrl: String?

    /// When the connection email was received.
    let extractedAt: Date

    /// Subject of the source email.
    let emailSubject: String

    /// Linked person ID once user claims this connection.
    var linkedPersonId: String?

    /// Whether user dismissed this connection without creating a person.
    var dismissed: Bool

    /// Creates a new LinkedIn connection record.
    ///
    /// - Parameters:
    ///   - name: Full name.
    ///   - profileUrl: Clean LinkedIn profile URL.
    ///   - headline: Optional profile headline.
    ///   - avatarUrl: Optional avatar URL.
    ///   - extractedAt: Timestamp of extraction.
    ///   - emailSubject: Source email subject.
    init(name: String, profileUrl: String, headline: String? = nil, avatarUrl: String? = nil, extractedAt: Date, emailSubject: String) {
        self.id = profileUrl.replacing(/[^a-zA-Z0-9]/, with: "_")
        self.name = name
        self.profileUrl = profileUrl
        self.headline = headline
        self.avatarUrl = avatarUrl
        self.extractedAt = extractedAt
        self.emailSubject = emailSubject
        self.linkedPersonId = nil
        self.dismissed = false
    }
}

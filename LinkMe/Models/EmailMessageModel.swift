import Foundation

/// A single email message processed by the email scanner.
///
/// Lightweight representation storing only metadata + scan results.
/// Full body is discarded after parsing to protect privacy.
struct EmailMessageModel: Identifiable {
    /// Stable unique ID (derived from messageId + from + timestamp hash).
    let id: String

    /// Sender email address.
    let from: String

    /// Email subject line.
    let subject: String

    /// Plain-text body (used for signature extraction).
    let body: String

    /// HTML body (used for LinkedIn parsing).
    let htmlBody: String?

    /// When the email was sent.
    let timestamp: Date

    /// Email Message-ID header (for deduplication).
    let messageId: String?

    /// When this email was processed by LinkMe.
    var scannedAt: Date?

    /// Type of signal found: "linkedin", "signature", "nudge", or "none".
    var scanType: String?

    /// Person ID linked to this email after processing.
    var linkedPersonId: String?

    /// Creates a new email message record.
    ///
    /// - Parameters:
    ///   - from: Sender email address.
    ///   - subject: Email subject line.
    ///   - body: Plain text body.
    ///   - htmlBody: Optional HTML body.
    ///   - timestamp: When the email was sent.
    ///   - messageId: Optional Message-ID header for deduplication.
    init(from: String, subject: String, body: String, htmlBody: String? = nil, timestamp: Date, messageId: String? = nil) {
        // Stable ID: hash of from + messageId + timestamp
        let key = "\(from):\(messageId ?? ""):\(Int64(timestamp.timeIntervalSince1970))"
        self.id = key.data(using: .utf8).map { Data($0).base64EncodedString() } ?? UUID().uuidString
        self.from = from
        self.subject = subject
        self.body = body
        self.htmlBody = htmlBody
        self.timestamp = timestamp
        self.messageId = messageId
    }
}

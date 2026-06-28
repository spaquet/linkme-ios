import Foundation

/// Current state of email scanning.
enum EmailScanState: Equatable {
    case off
    case needsPermission
    case scanning
    case idle
    case failed(String)

    var label: String {
        switch self {
        case .off: "Off"
        case .needsPermission: "Needs permission"
        case .scanning: "Scanning"
        case .idle: "Idle"
        case .failed: "Failed"
        }
    }
}

/// Stats from the latest email scan.
struct EmailScanStats {
    /// Emails processed in last scan.
    var scanned = 0
    /// LinkedIn connections found.
    var linkedInFound = 0
    /// New persons created.
    var personsCreated = 0
    /// Threads created.
    var threadsCreated = 0
    /// When scan last completed.
    var lastScannedAt: Date?
}

/// Orchestrates email scanning across providers.
///
/// Phase 1: Apple Mail only. Detects LinkedIn connections, extracts person data,
/// creates Person + Thread + Nudge records.
///
/// - Important: Apple Mail access requires user permission.
///   Gmail/Outlook scanning stubbed for Phase 4.
@Observable
@MainActor
final class EmailScanManager {
    /// Shared singleton instance.
    static let shared = EmailScanManager()

    /// Whether scanning is in progress.
    var isScanning = false

    /// Current scanner state.
    var state: EmailScanState = .idle

    /// Stats from latest scan run.
    var stats = EmailScanStats()

    /// LinkedIn connections found, pending user action.
    var pendingLinkedInConnections: [LinkedInConnection] = []

    private init() {
        pendingLinkedInConnections = DatabaseManager.shared.fetchPendingLinkedInConnections()
    }

    // MARK: - Apple Mail

    /// Scan Apple Mail for LinkedIn connection emails.
    ///
    /// Fetches recent emails, runs LinkedIn parser, creates persons and threads.
    func scanAppleMail() async {
        guard !isScanning else { return }
        isScanning = true
        state = .scanning
        defer {
            isScanning = false
            state = .idle
            stats.lastScannedAt = Date()
        }

        let emails = await fetchAppleMailMessages()
        var localStats = EmailScanStats()
        localStats.scanned = emails.count

        for email in emails {
            guard !DatabaseManager.shared.emailMessageExists(id: email.id) else { continue }
            processEmail(email, stats: &localStats)
            DatabaseManager.shared.insertEmailMessage(email)
        }

        stats = localStats
        stats.lastScannedAt = Date()
        pendingLinkedInConnections = DatabaseManager.shared.fetchPendingLinkedInConnections()
    }

    // MARK: - Processing

    private func processEmail(_ email: EmailMessageModel, stats: inout EmailScanStats) {
        if let connection = LinkedInParser.parse(email) {
            guard !DatabaseManager.shared.linkedInConnectionExists(id: connection.id) else { return }

            let person = findOrCreatePerson(from: connection)
            var savedConnection = connection
            savedConnection.linkedPersonId = person.id

            DatabaseManager.shared.insertLinkedInConnection(savedConnection)

            var thread = ThreadModel(
                personId: person.id,
                prompt: "Reach out to \(person.name) — connected on LinkedIn"
            )
            thread.dueAt = Date().addingTimeInterval(7 * 24 * 3600)
            DatabaseManager.shared.insertThread(thread)

            let nudge = NudgeModel(
                personId: person.id,
                kind: "signal",
                title: "New LinkedIn connection: \(person.name)",
                detail: connection.headline ?? "Connected on LinkedIn",
                cta: "Reach out"
            )
            DatabaseManager.shared.insertNudge(nudge)

            stats.linkedInFound += 1
            stats.threadsCreated += 1
        }
    }

    private func findOrCreatePerson(from connection: LinkedInConnection) -> PersonModel {
        let (role, company) = parseHeadline(connection.headline)

        if let existing = EmailContactMatcher.findPerson(name: connection.name, company: company) {
            return existing
        }

        var person = PersonModel(
            name: connection.name,
            company: company ?? "",
            role: role ?? ""
        )
        person.linkedInProfileUrl = connection.profileUrl
        DatabaseManager.shared.insertPerson(person)
        return person
    }

    /// Parse "Role at Company" headline into (role, company).
    private func parseHeadline(_ headline: String?) -> (String?, String?) {
        guard let headline else { return (nil, nil) }
        let parts = headline.components(separatedBy: " at ")
        if parts.count == 2 {
            return (parts[0].trimmingCharacters(in: .whitespaces),
                    parts[1].trimmingCharacters(in: .whitespaces))
        }
        return (headline, nil)
    }

    // MARK: - Apple Mail Fetch (Phase 1 stub)

    /// Fetch recent emails from Apple Mail.
    ///
    /// - Important: Replace with Mail.framework integration in Phase 3.
    ///   Returns empty array until framework access is confirmed.
    private func fetchAppleMailMessages() async -> [EmailMessageModel] {
        // TODO: Integrate with Mail.framework or MailKit (iOS 26)
        return []
    }

    // MARK: - Gmail

    /// Scan Gmail for LinkedIn connection emails using stored OAuth token.
    func scanGmail() async {
        guard !isScanning else { return }
        isScanning = true
        state = .scanning
        defer {
            isScanning = false
            state = .idle
            stats.lastScannedAt = Date()
        }

        do {
            let emails = try await GmailAPIClient.shared.fetchLinkedInEmails()
            var localStats = EmailScanStats()
            localStats.scanned = emails.count

            for email in emails {
                guard !DatabaseManager.shared.emailMessageExists(id: email.id) else { continue }
                processEmail(email, stats: &localStats)
                DatabaseManager.shared.insertEmailMessage(email)
            }

            stats = localStats
            stats.lastScannedAt = Date()
            pendingLinkedInConnections = DatabaseManager.shared.fetchPendingLinkedInConnections()
        } catch {
            state = .failed(error.localizedDescription)
            isScanning = false
        }
    }

    /// Scan Outlook inbox (future).
    func scanOutlook(accessToken: String) async throws {
        throw EmailScanError.notImplemented("Outlook scanning not yet available.")
    }
}

/// Errors from email scanning operations.
enum EmailScanError: LocalizedError {
    case notImplemented(String)
    case noPermission
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notImplemented(let msg): return msg
        case .noPermission: return "Email access not granted."
        case .networkError(let msg): return "Network error: \(msg)"
        }
    }
}

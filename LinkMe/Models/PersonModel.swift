import Foundation

struct PersonModel: Identifiable, Hashable {
    let id: String
    var name: String
    var company: String
    var role: String
    var tone: String // teal, slate, amber, indigo, rose, sky
    var initials: String
    var capturedAt: Date
    var updatedAt: Date
    var lastContact: Date?
    var isFavorite: Bool
    var notes: [String] = []
    var tags: [String] = []
    var deletedAt: Date?
    var context: String = ""
    var openThreads: [String] = []
    var talkingPoints: [String] = []
    var personal: String = ""
    var shared: [String] = []
    var timeline: [TimelineEntry] = []
    var location: String = ""
    var met: String = "Met once"
    var followup: String = ""
    var appleContactIdentifier: String?
    var appleContactLastSyncedAt: Date?
    var appleContactSyncChecksum: String?
    var appleContactSnapshotJson: String?

    init(id: String = UUID().uuidString, name: String, company: String, role: String) {
        self.id = id
        self.name = name
        self.company = company
        self.role = role
        self.tone = "teal"
        self.initials = Self.computeInitials(name)
        self.capturedAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
    }

    nonisolated static func computeInitials(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let words = trimmed.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

        guard !words.isEmpty else { return "" }

        if words.count == 1 {
            let segments = trimmed.split(whereSeparator: { $0 == "-" || $0 == "'" })
                .map(String.init)
            return segments.prefix(2)
                .compactMap { $0.first }
                .map { String($0) }
                .joined()
                .uppercased()
        }

        let firstInitial = String(words[0].first ?? " ")
        let lastName = Self.removeParticles(from: words.last ?? "")
        let lastInitial = String(lastName.first ?? " ")

        return (firstInitial + lastInitial).uppercased()
    }

    private nonisolated static func removeParticles(from lastName: String) -> String {
        let particles = ["d'", "de ", "du ", "la ", "le ", "van ", "von ", "von d'"]
        let lowerName = lastName.lowercased()

        for particle in particles {
            if lowerName.hasPrefix(particle) {
                let remaining = String(lastName.dropFirst(particle.count))
                    .trimmingCharacters(in: .whitespaces)
                if !remaining.isEmpty { return remaining }
            }
        }

        return lastName
    }
}

struct TimelineEntry: Hashable {
    let kind: String // capture, meet, note
    let label: String
    let date: String
    let detail: String?
}

struct NoteModel: Identifiable {
    let id: String
    let personId: String
    var text: String
    var transcription: String?
    var extractedJson: [String: String] = [:]
    var createdAt: Date
    var isFollowUp: Bool

    init(id: String = UUID().uuidString, personId: String, text: String, transcription: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.personId = personId
        self.text = text
        self.transcription = transcription
        self.createdAt = createdAt
        self.isFollowUp = false
    }
}

struct ContactModel: Identifiable {
    let id: String
    let personId: String
    var type: String // meeting, call, text
    var timestamp: Date
    var location: String?
    var attendees: [String] = []
    var appleContactIdentifier: String?
    var appleContactMatchKey: String?
    var lastSyncedAt: Date?
    var syncChecksum: String?

    init(personId: String, type: String = "meeting") {
        self.id = UUID().uuidString
        self.personId = personId
        self.type = type
        self.timestamp = Date()
    }
}

struct ThreadModel: Identifiable {
    let id: String
    let personId: String
    var prompt: String
    var status: String // open, closed, snoozed
    var createdAt: Date
    var dueAt: Date?

    init(personId: String, prompt: String) {
        self.id = UUID().uuidString
        self.personId = personId
        self.prompt = prompt
        self.status = "open"
        self.createdAt = Date()
    }
}

struct ShareModel: Identifiable {
    let id: String
    let personId: String
    var cardId: String?
    var token: String
    var sentAt: Date
    var sentTo: String?
    var openedAt: Date?
    var viewedCount: Int
    var claimedByPersonId: String?
    var expiresAt: Date?

    init(personId: String, cardId: String? = nil, sentTo: String? = nil, expiresAt: Date? = nil) {
        self.id = UUID().uuidString
        self.personId = personId
        self.cardId = cardId
        self.token = UUID().uuidString
        self.sentAt = Date()
        self.sentTo = sentTo
        self.viewedCount = 0
        self.expiresAt = expiresAt
    }
}

struct RelationshipModel: Identifiable {
    let id: String
    let personAId: String
    let personBId: String
    var sharedConnectionDate: Date?

    init(personAId: String, personBId: String) {
        self.id = UUID().uuidString
        self.personAId = personAId
        self.personBId = personBId
    }
}

struct NudgeModel: Identifiable {
    let id: String
    let personId: String
    var kind: String // signal, promise, followup
    var title: String
    var detail: String
    var cta: String

    init(id: String = UUID().uuidString, personId: String, kind: String, title: String, detail: String, cta: String) {
        self.id = id
        self.personId = personId
        self.kind = kind
        self.title = title
        self.detail = detail
        self.cta = cta
    }
}

/// A standalone note not tied to any person or contact.
///
/// Standalone notes are free-form text entries for capturing thoughts, reminders, or context
/// that don't belong to a specific person's record. They can be searched and filtered by creation date.
///
/// - Note: Unlike ``NoteModel``, standalone notes have no foreign key relationship and are
///   managed independently in the database.
struct StandaloneNoteModel: Identifiable {
    /// Unique identifier for this note.
    let id: String

    /// User-provided text content of the note.
    var text: String

    /// Optional speech-to-text transcription if note was created via voice.
    var transcription: String?

    /// Optional structured data extracted by AI from the note content.
    var extractedJson: [String: String]

    /// Timestamp when the note was created.
    var createdAt: Date

    /// Optional timestamp when the note was last modified.
    var updatedAt: Date?

    /// Optional tags for categorizing or filtering standalone notes.
    var tags: [String]

    /// Creates a new standalone note.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Auto-generated if not provided.
    ///   - text: The note content (required).
    ///   - transcription: Optional speech-to-text transcription.
    ///   - extractedJson: Optional structured extraction results.
    ///   - createdAt: Timestamp of creation (defaults to now).
    ///   - updatedAt: Timestamp of last modification.
    ///   - tags: Optional tags for categorization.
    init(
        id: String = UUID().uuidString,
        text: String,
        transcription: String? = nil,
        extractedJson: [String: String] = [:],
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.text = text
        self.transcription = transcription
        self.extractedJson = extractedJson
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? Date()
        self.tags = tags
    }
}

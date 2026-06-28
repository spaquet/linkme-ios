import Foundation

/// A person record in the LinkMe system.
///
/// Represents a contact captured via voice note, manual entry, or sync from Apple Contacts.
/// Stores profile, relationship context, and interaction history.
///
/// - Important: PersonModel is the core of LinkMe's single-player layer. Properties like
///   `openThreads`, `talkingPoints`, and `personal` are hydrated by AI extraction and briefing queries;
///   they are not persisted to the database and should not be edited by the user.
struct PersonModel: Identifiable, Hashable {
    /// Unique identifier for this person.
    let id: String

    /// Full name as captured.
    var name: String

    /// Company or organization.
    var company: String

    /// Job title or role.
    var role: String

    /// Design token color for avatar: teal, slate, amber, indigo, rose, or sky.
    var tone: String // teal, slate, amber, indigo, rose, sky

    /// Two-letter initials derived from name (e.g., "MS" for Marcus Smith).
    var initials: String

    /// Timestamp when person was first captured.
    var capturedAt: Date

    /// Timestamp of the last update to this person's record.
    var updatedAt: Date

    /// Timestamp of the most recent interaction with this person.
    var lastContact: Date?

    /// Whether this person is marked as a favorite.
    var isFavorite: Bool

    /// Free-form text notes associated with this person (deprecated; use notes table in database).
    var notes: [String] = []

    /// Tags for categorizing or filtering people.
    var tags: [String] = []

    /// Soft-delete timestamp; nil if person is active.
    var deletedAt: Date?

    /// Context summary extracted from voice notes (AI-generated).
    var context: String = ""

    /// Open follow-up items or promises (AI-generated).
    var openThreads: [String] = []

    /// AI-generated talking points for just-in-time briefing.
    var talkingPoints: [String] = []

    /// Personal details or preferences (AI-extracted).
    var personal: String = ""

    /// List of mutual connections or shared relationships.
    var shared: [String] = []

    /// Chronological timeline of captures, meetings, and interactions.
    var timeline: [TimelineEntry] = []

    /// Location of person or last known location.
    var location: String = ""

    /// Relationship cadence label (e.g., "Met once", "Monthly calls").
    var met: String = "Met once"

    /// Next follow-up action or task.
    var followup: String = ""

    /// LinkedIn profile URL if connected.
    var linkedInProfileUrl: String?

    /// Apple Contacts identifier for sync matching (iOS 26+).
    var appleContactIdentifier: String?

    /// Timestamp of last successful sync with Apple Contacts.
    var appleContactLastSyncedAt: Date?

    /// Checksum of last synced contact snapshot for change detection.
    var appleContactSyncChecksum: String?

    /// JSON snapshot of the contact as seen at last sync.
    var appleContactSnapshotJson: String?

    /// Creates a new person record.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided).
    ///   - name: Full name of the person.
    ///   - company: Company or organization.
    ///   - role: Job title or role.
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

    /// Derives two-letter initials from a person's name.
    ///
    /// Handles multi-word names (first + last), hyphenated names, and particles (de, van, von).
    /// Falls back to first two letters if only one word.
    ///
    /// - Parameters:
    ///   - name: The person's full name.
    ///
    /// - Returns: Two uppercase letters (e.g., "MS" for "Marcus Smith", "JD" for "Jean de Gaulle").
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

    /// Strips French/Dutch name particles from a last name.
    ///
    /// Removes prefixes like "de", "van", "von" to extract the core surname for initials.
    ///
    /// - Parameters:
    ///   - lastName: The last name, potentially with a particle prefix.
    ///
    /// - Returns: The last name without particle prefix.
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

/// A single event in a person's interaction timeline.
///
/// Represents a capture, meeting, note, or contact event. Displayed chronologically
/// in the person detail view.
struct TimelineEntry: Hashable {
    /// Event type: "capture", "meet", "note", or "contact".
    let kind: String // capture, meet, note

    /// Human-readable title or description.
    let label: String

    /// ISO8601 date string of the event.
    let date: String

    /// Optional additional context or summary.
    let detail: String?
}

/// A note attached to a specific person.
///
/// Captures voice-to-text transcriptions and extracted structured data from a single capture event.
/// Unlike ``StandaloneNoteModel``, a note is always bound to a person record.
struct NoteModel: Identifiable {
    /// Unique identifier for this note.
    let id: String

    /// The person this note belongs to.
    let personId: String

    /// Final text content of the note (transcribed and/or edited).
    var text: String

    /// Raw speech-to-text transcription if created via voice.
    var transcription: String?

    /// Structured data extracted by AI (e.g., role, company, follow-up).
    var extractedJson: [String: String] = [:]

    /// Timestamp when the note was created.
    var createdAt: Date

    /// Whether this note represents a follow-up commitment.
    var isFollowUp: Bool

    /// Creates a new note for a person.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided).
    ///   - personId: The person this note belongs to.
    ///   - text: The note content.
    ///   - transcription: Optional speech-to-text result.
    ///   - createdAt: Timestamp of creation (defaults to now).
    init(id: String = UUID().uuidString, personId: String, text: String, transcription: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.personId = personId
        self.text = text
        self.transcription = transcription
        self.createdAt = createdAt
        self.isFollowUp = false
    }
}

/// A single interaction with a person (meeting, call, or text).
///
/// Tracks the when, where, and who of a person interaction. Can be manually logged
/// or synced from Apple Contacts.
struct ContactModel: Identifiable {
    /// Unique identifier for this contact event.
    let id: String

    /// The person involved in this contact event.
    let personId: String

    /// Type of contact: "meeting", "call", or "text".
    var type: String // meeting, call, text

    /// When the contact occurred.
    var timestamp: Date

    /// Where the meeting took place (if applicable).
    var location: String?

    /// Other people present in this contact.
    var attendees: [String] = []

    /// Apple Contacts identifier for sync matching.
    var appleContactIdentifier: String?

    /// Contact match key used during incremental sync.
    var appleContactMatchKey: String?

    /// Timestamp of the last sync with Apple Contacts.
    var lastSyncedAt: Date?

    /// Checksum of the synced contact snapshot.
    var syncChecksum: String?

    /// Creates a new contact event.
    ///
    /// - Parameters:
    ///   - personId: The person involved.
    ///   - type: Type of contact (meeting, call, text).
    init(personId: String, type: String = "meeting") {
        self.id = UUID().uuidString
        self.personId = personId
        self.type = type
        self.timestamp = Date()
    }
}

/// A follow-up task or conversation thread.
///
/// Represents an open commitment, promise, or reminder tied to a person.
/// Displayed in the Threads (notifications) view and Needs You section of Today.
struct ThreadModel: Identifiable {
    /// Unique identifier for this thread.
    let id: String

    /// The person this thread is about.
    let personId: String

    /// Description of the follow-up action or commitment.
    var prompt: String

    /// Current status: "open", "closed", or "snoozed".
    var status: String // open, closed, snoozed

    /// When this thread was created.
    var createdAt: Date

    /// Optional due date for the follow-up.
    var dueAt: Date?

    /// Creates a new follow-up thread.
    ///
    /// - Parameters:
    ///   - personId: The person this thread is about.
    ///   - prompt: Description of the follow-up action.
    init(personId: String, prompt: String) {
        self.id = UUID().uuidString
        self.personId = personId
        self.prompt = prompt
        self.status = "open"
        self.createdAt = Date()
    }
}

/// A share-back invitation sent to a contact.
///
/// Tracks the distribution and interaction with a no-app web card sent to a person.
/// Enables the recipient to claim their own profile and close the loop.
struct ShareModel: Identifiable {
    /// Unique identifier for this share.
    let id: String

    /// The person whose card is being shared.
    let personId: String

    /// Optional reference to the card being shared.
    var cardId: String?

    /// Unique token used in the share link (URL-safe).
    var token: String

    /// When the share link was sent.
    var sentAt: Date

    /// Email or contact info the share was sent to.
    var sentTo: String?

    /// When the share link was first opened by the recipient.
    var openedAt: Date?

    /// Number of times the share link has been viewed.
    var viewedCount: Int

    /// If claimed, the person ID of the claimant.
    var claimedByPersonId: String?

    /// Optional expiration date for the share link.
    var expiresAt: Date?

    /// Creates a new share record.
    ///
    /// - Parameters:
    ///   - personId: The person whose card is being shared.
    ///   - cardId: Optional reference to the card.
    ///   - sentTo: Optional email or contact destination.
    ///   - expiresAt: Optional link expiration date.
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

/// A mutual connection between two people.
///
/// Represents a shared relationship graph edge. Used to show "Shared Connections"
/// in the briefing view and to seed future "Scenes" or event-based group views.
struct RelationshipModel: Identifiable {
    /// Unique identifier for this relationship.
    let id: String

    /// The first person in the connection.
    let personAId: String

    /// The second person in the connection.
    let personBId: String

    /// When the shared connection was discovered or recorded.
    var sharedConnectionDate: Date?

    /// Creates a new mutual connection record.
    ///
    /// - Parameters:
    ///   - personAId: First person.
    ///   - personBId: Second person.
    init(personAId: String, personBId: String) {
        self.id = UUID().uuidString
        self.personAId = personAId
        self.personBId = personBId
    }
}

/// A nudge or reminder to act on a person-related task.
///
/// Shown in the "Needs You" section of Today or the Threads view.
/// Nudges aggregate open threads, promises, and follow-ups into actionable items.
struct NudgeModel: Identifiable {
    /// Unique identifier for this nudge.
    let id: String

    /// The person this nudge is about.
    let personId: String

    /// Category: "signal" (AI insight), "promise" (you owe them), or "followup" (they're waiting).
    var kind: String // signal, promise, followup

    /// Short headline for the nudge.
    var title: String

    /// Longer context or reason for the nudge.
    var detail: String

    /// Call-to-action label (e.g., "Brief me", "Send followup", "Reach out").
    var cta: String

    /// Creates a new nudge.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided).
    ///   - personId: The person this nudge is about.
    ///   - kind: Nudge category (signal, promise, or followup).
    ///   - title: Short headline.
    ///   - detail: Supporting context.
    ///   - cta: Call-to-action label.
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

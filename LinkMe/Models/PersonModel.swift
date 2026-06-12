import Foundation

struct PersonModel: Identifiable, Hashable {
    let id: String
    var name: String
    var company: String
    var role: String
    var tone: String // teal, slate, amber, indigo, rose, sky
    var capturedAt: Date
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
        self.capturedAt = Date()
        self.isFavorite = false
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

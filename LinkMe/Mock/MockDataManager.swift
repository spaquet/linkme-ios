import Foundation

enum MockDataManager {
    static let mockPeople: [PersonModel] = [
        PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"),
        PersonModel(id: "2", name: "Sarah Johnson", company: "Acme Corp", role: "VP Product"),
        PersonModel(id: "3", name: "Alex Rivera", company: "TechStart", role: "Founder & CEO"),
        PersonModel(id: "4", name: "Jamie Lee", company: "Ventures Inc", role: "Partner"),
        PersonModel(id: "5", name: "Chris Wang", company: "Growth Labs", role: "Director"),
    ]

    static let mockNotes: [NoteModel] = [
        NoteModel(personId: "1", text: "Leading venture fund close this month. Interested in data infra space.", transcription: "leading venture fund close this month interested in data infra space"),
        NoteModel(personId: "2", text: "Product launch planned for Q3. Needs feedback on UX flows.", transcription: "product launch planned for Q3 needs feedback on UX flows"),
        NoteModel(personId: "3", text: "Series B fundraising in progress. Offered intro to Naomi.", transcription: "series B fundraising in progress offered intro to Naomi"),
    ]

    static let mockThreads: [ThreadModel] = [
        ThreadModel(personId: "1", prompt: "Send data-infra memo"),
        ThreadModel(personId: "1", prompt: "Share Naomi intro"),
        ThreadModel(personId: "2", prompt: "Promised product demo feedback"),
    ]

    static func getSharedConnections(for personId: String) -> [PersonModel] {
        mockPeople.filter { $0.id != personId }
    }

    static func getNotesForPerson(_ personId: String) -> [NoteModel] {
        mockNotes.filter { $0.personId == personId }
    }

    static func getThreadsForPerson(_ personId: String) -> [ThreadModel] {
        mockThreads.filter { $0.personId == personId }
    }
}

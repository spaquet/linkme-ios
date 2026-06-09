import Foundation

enum MockDataManager {
    static let mockPeople: [PersonModel] = {
        var people = [
            PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"),
            PersonModel(id: "2", name: "Sarah Johnson", company: "Acme Corp", role: "VP Product"),
            PersonModel(id: "3", name: "Alex Rivera", company: "TechStart", role: "Founder & CEO"),
            PersonModel(id: "4", name: "Jamie Lee", company: "Ventures Inc", role: "Partner"),
            PersonModel(id: "5", name: "Chris Wang", company: "Growth Labs", role: "Director"),
        ]
        people[0].tags = ["Investor", "Angel"]
        people[0].lastContact = Calendar.current.date(byAdding: .day, value: -5, to: Date())

        people[1].tags = ["Exec"]
        people[1].lastContact = Calendar.current.date(byAdding: .month, value: -3, to: Date())

        people[2].tags = ["Founder"]
        people[2].lastContact = Calendar.current.date(byAdding: .month, value: -11, to: Date())

        people[3].tags = ["Investor"]
        people[3].lastContact = Calendar.current.date(byAdding: .year, value: -1, to: Date())

        people[4].tags = ["Exec"]
        people[4].lastContact = Calendar.current.date(byAdding: .month, value: -2, to: Date())

        return people
    }()

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

    static let mockNudges: [NudgeModel] = [
        NudgeModel(personId: "3", kind: "followup", title: "Follow up with Alex Rivera", detail: "You met 6 days ago and haven't followed up. Reciprocity window is closing.", cta: "Draft follow-up"),
        NudgeModel(personId: "2", kind: "signal", title: "Sarah Johnson closed a Series A", detail: "Public signal picked up 2 weeks ago. A congrats note compounds the relationship.", cta: "Congratulate"),
        NudgeModel(personId: "4", kind: "promise", title: "You promised Jamie an intro", detail: "You offered to connect Jamie to Marcus 2 days ago. Marcus is warm to it.", cta: "Make the intro"),
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

    static func getNudges() -> [NudgeModel] {
        mockNudges
    }
}

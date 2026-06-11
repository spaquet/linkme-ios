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

        // Assign tags and lastContact dates for filter and time formatting testing
        people[0].tags = ["Investor", "Angel"]
        people[0].lastContact = Calendar.current.date(byAdding: .day, value: -5, to: Date())
        people[0].location = "Founders Circuit · Battery SF"
        people[0].met = "Met 5 days ago"
        people[0].context = "Closing Meridian's third fund (~$400M); actively writing seed checks in AI infrastructure this quarter."
        people[0].openThreads = ["Send data-infra memo", "Share Naomi intro"]
        people[0].talkingPoints = [
          "Fund closing this month for $200M",
          "Primary focus on infrastructure and tooling",
          "Strong technical track record with exits",
          "Actively mentoring 3 portfolio founders"
        ]
        people[0].personal = "Passionate about hiking. Recently climbed Denali. Coffee enthusiast — only drinks single-origin Ethiopian."
        people[0].shared = ["Sarah Johnson", "Alex Rivera"]
        people[0].followup = "Marcus — great catching up over coffee. Sending the updated metrics deck now; the Q2 retention curve is the part I'd flag. Also happy to make that intro to Naomi at Cedar whenever useful."
        people[0].timeline = [
            TimelineEntry(kind: "capture", label: "Voice note", date: "Today", detail: "Leading venture fund close this month. Interested in data infra space."),
            TimelineEntry(kind: "meet", label: "Coffee meeting", date: "5 days ago", detail: "Discussed market opportunity in data tooling"),
            TimelineEntry(kind: "note", label: "Follow-up sent", date: "4 days ago", detail: nil),
            TimelineEntry(kind: "capture", label: "Voice note", date: "2 days ago", detail: "Mentioned series B round timeline"),
        ]

        people[1].tags = ["Exec"]
        people[1].lastContact = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        people[1].location = "SoHo Lofts · New York"
        people[1].met = "Met 3 months ago"
        people[1].context = "Product launch planned for Q3. Needs feedback on UX flows. Leading product overhaul for enterprise customers."
        people[1].openThreads = ["Promised product demo feedback"]
        people[1].talkingPoints = [
          "Q3 product launch targeting enterprise tier",
          "Building new analytics dashboard",
          "Team expanded to 15 people",
          "Considering Series A extension round"
        ]
        people[1].personal = "New parent. Loves photography. Recently won local photo competition. Lives in Brooklyn."
        people[1].shared = ["Marcus Chen", "Chris Wang"]
        people[1].followup = "Sarah — congrats on the Series A. Really excited to see the product launch ship in Q3. Happy to help with early customer intros if useful."
        people[1].timeline = [
            TimelineEntry(kind: "capture", label: "Voice note", date: "3 months ago", detail: "Product launch planned for Q3"),
            TimelineEntry(kind: "meet", label: "Product review call", date: "2 months ago", detail: nil),
            TimelineEntry(kind: "capture", label: "Voice note", date: "6 weeks ago", detail: "Team expansion and new hire updates"),
        ]

        people[2].tags = ["Founder"]
        people[2].lastContact = Calendar.current.date(byAdding: .month, value: -11, to: Date())
        people[2].location = "Mission District · San Francisco"
        people[2].met = "Met 11 months ago"
        people[2].context = "Series B fundraising in progress. Offered intro to Naomi. Early-stage marketplace platform."
        people[2].openThreads = []
        people[2].talkingPoints = [
          "Series B round targeting $5M",
          "2-sided marketplace model",
          "Strong user retention metrics",
          "Expanding to 3 new markets"
        ]
        people[2].personal = "Avid rock climber. Competes in indoor competitions. Vegan. Interested in sustainable business practices."
        people[2].shared = ["Marcus Chen"]
        people[2].followup = "Alex — great meeting you. Would love to keep the conversation going on the Series B round."
        people[2].timeline = [
            TimelineEntry(kind: "capture", label: "Voice note", date: "11 months ago", detail: "Series B fundraising in progress"),
            TimelineEntry(kind: "meet", label: "Initial meeting", date: "11 months ago", detail: nil),
        ]

        people[3].tags = ["Investor"]
        people[3].lastContact = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        people[3].location = "SOMA · San Francisco"
        people[3].met = "Met 1 year ago"
        people[3].context = "Angel investor in mobile apps. Promised Jamie an intro to Marcus. Deep expertise in monetization."
        people[3].openThreads = ["You promised Jamie an intro"]
        people[3].talkingPoints = [
          "Expert in app monetization strategies",
          "20+ exits in mobile space",
          "Active advisor to 5 startups",
          "Speaking at TechCrunch Disrupt"
        ]
        people[3].personal = "Marathon runner. Recently completed Boston Marathon. Coffee shop nomad. Active on Twitter."
        people[3].shared = ["Sarah Johnson"]
        people[3].followup = "Jamie — connecting you with Marcus at Meridian. You'll definitely click on the fintech side."
        people[3].timeline = [
            TimelineEntry(kind: "meet", label: "Pitch meeting", date: "1 year ago", detail: nil),
        ]

        people[4].tags = ["Exec"]
        people[4].lastContact = Calendar.current.date(byAdding: .month, value: -2, to: Date())
        people[4].location = "Marina District · San Francisco"
        people[4].met = "Met 2 months ago"
        people[4].context = "Director of partnerships. Growing team to 10 people. Focus on enterprise sales expansion."
        people[4].openThreads = []
        people[4].talkingPoints = [
          "Building partnerships across Fortune 500",
          "Enterprise sales pipeline growing 40% MoM",
          "Team expansion from 5 to 10 people",
          "Focus on vertical integration"
        ]
        people[4].personal = "Board game enthusiast. Hosts monthly game nights. Enjoys woodworking in spare time."
        people[4].shared = ["Sarah Johnson"]
        people[4].followup = "Chris — really enjoyed the lunch. Let's stay in touch on partnership opportunities."
        people[4].timeline = [
            TimelineEntry(kind: "capture", label: "Voice note", date: "2 months ago", detail: "Partnership expansion discussion"),
            TimelineEntry(kind: "meet", label: "Lunch meeting", date: "2 months ago", detail: nil),
            TimelineEntry(kind: "capture", label: "Voice note", date: "1 month ago", detail: "Team growth update"),
        ]

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

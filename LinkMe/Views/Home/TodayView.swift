import EventKit
import SwiftUI

struct TodayCalendarEvent: Identifiable {
    enum EventKind {
        case meeting
        case lunch
        case dinner
        case coffee
        case drinks
        case sport

        var icon: String {
            switch self {
            case .meeting: return "calendar"
            case .lunch: return "fork.knife"
            case .dinner: return "moon.stars"
            case .coffee: return "cup.and.saucer"
            case .drinks: return "wineglass"
            case .sport: return "figure.run"
            }
        }

        var label: String {
            switch self {
            case .meeting: return "Meeting"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .coffee: return "Coffee"
            case .drinks: return "Drinks"
            case .sport: return "Sport"
            }
        }
    }

    let id: String
    let startsAt: Date
    let title: String
    let location: String
    let person: PersonModel?
    let attendeeCount: Int
    let kind: EventKind
    let channel: String
    let briefing: String

    var formattedTime: String {
        Self.timeFormatter.string(from: startsAt)
    }

    var displayName: String {
        person?.name ?? title
    }

    var subtitle: String {
        if let person {
            return "\(person.role) · \(person.company)"
        }
        return location
    }

    var isGroupEvent: Bool {
        attendeeCount > 1
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static var mockCalendar: [TodayCalendarEvent] {
        let calendar = Calendar.current
        let now = Date()

        func todayAt(hour: Int, minute: Int = 0) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? now
        }

        let people = MockDataManager.mockPeople
        return [
            TodayCalendarEvent(
                id: "meridian-partner-checkin",
                startsAt: todayAt(hour: 15),
                title: "Meridian partner check-in",
                location: "Zoom",
                person: people.first { $0.id == "1" },
                attendeeCount: 1,
                kind: .meeting,
                channel: "Zoom",
                briefing: "He owes you the data-infra memo, and you offered the Naomi intro. Lead with the fund close, announced Tuesday."
            ),
            TodayCalendarEvent(
                id: "team-sync",
                startsAt: todayAt(hour: 16, minute: 30),
                title: "Team sync",
                location: "Conference room",
                person: nil,
                attendeeCount: 6,
                kind: .meeting,
                channel: "In person",
                briefing: "Check open capture cleanup and confirm the onboarding copy changes before the next build."
            ),
            TodayCalendarEvent(
                id: "alex-dinner",
                startsAt: todayAt(hour: 18),
                title: "Dinner with Alex",
                location: "Downtown",
                person: people.first { $0.id == "3" },
                attendeeCount: 1,
                kind: .dinner,
                channel: "In person",
                briefing: "Alex is raising a Series B and previously mentioned Naomi. Ask where the round stands before offering a new intro."
            )
        ]
    }
}

struct TodayView: View {
    let navigationManager: NavigationManager
    let appState: AppState
    @Binding var selectedTab: Int
    @State private var recentCaptures: [PersonModel] = []
    @State private var nudges: [NudgeModel] = MockDataManager.mockNudges
    @State private var calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    private let eventStore = EKEventStore()

    private var isCalendarConnected: Bool {
        calendarAuthorizationStatus == .fullAccess
    }

    private var upcomingEvents: [TodayCalendarEvent] {
        TodayCalendarEvent.mockCalendar
            .filter { $0.startsAt >= Date() }
            .sorted { $0.startsAt < $1.startsAt }
    }

    private var upNextEvent: TodayCalendarEvent? {
        upcomingEvents.first
    }

    private var laterTodayEvents: [TodayCalendarEvent] {
        Array(upcomingEvents.dropFirst().prefix(2))
    }

    private var calendarPreviewEvents: [TodayCalendarEvent] {
        Array(TodayCalendarEvent.mockCalendar.dropFirst().prefix(2))
    }

    private func loadRecentCaptures() {
        recentCaptures = Array(DatabaseManager.shared.fetchPeople().prefix(10))
    }

    private func requestCalendarAccess() {
        Task {
            do {
                if #available(iOS 17.0, *) {
                    _ = try await eventStore.requestFullAccessToEvents()
                } else {
                    let _: Bool = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                        eventStore.requestAccess(to: .event) { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: granted)
                            }
                        }
                    }
                }

                await MainActor.run {
                    calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
                }
            } catch {
                await MainActor.run {
                    calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
                }
            }
        }
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                TopBar(appState: appState, navigationManager: navigationManager, selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .padding(.top, LinkMeLayout.statusBarHeight - 20)

                // Content
                ScrollView {
                    VStack(spacing: 22) {
                        // UP NEXT
                        if isCalendarConnected, let upNextEvent {
                            VStack(spacing: 10) {
                                SectionLabel("Up next · \(upNextEvent.formattedTime)")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                UpNextCard(event: upNextEvent, navigationManager: navigationManager)
                            }
                        } else if isCalendarConnected {
                            VStack(spacing: 10) {
                                SectionLabel("Up next")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                EmptyCalendarDayCard()
                            }
                        } else {
                            VStack(spacing: 10) {
                                SectionLabel("Up next")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ConnectCalendarCard {
                                    requestCalendarAccess()
                                }
                            }
                        }

                        // LATER TODAY
                        if isCalendarConnected, !laterTodayEvents.isEmpty {
                            VStack(spacing: 10) {
                                SectionLabel("Later today")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Card(padding: 0) {
                                    VStack(spacing: 0) {
                                        ForEach(Array(laterTodayEvents.enumerated()), id: \.element.id) { index, event in
                                            LaterTodayItem(event: event)

                                            if index < laterTodayEvents.count - 1 {
                                                Divider(inset: 68)
                                            }
                                        }
                                    }
                                }
                            }
                        } else if !isCalendarConnected, !calendarPreviewEvents.isEmpty {
                            VStack(spacing: 10) {
                                SectionLabel("Later today")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Card(padding: 0) {
                                    VStack(spacing: 0) {
                                        ForEach(Array(calendarPreviewEvents.enumerated()), id: \.element.id) { index, event in
                                            LaterTodayItem(event: event, isPreview: true)

                                            if index < calendarPreviewEvents.count - 1 {
                                                Divider(inset: 68)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // NEEDS YOU
                        VStack(spacing: 10) {
                            HStack {
                                SectionLabel("Needs you")
                                Spacer()
                                Button(action: {
                                    selectedTab = 3
                                }) {
                                    Text("All threads")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(LinkMeColors.t700)
                                }
                            }

                            VStack(spacing: 10) {
                                ForEach(nudges.prefix(2), id: \.id) { nudge in
                                    NeedsYouCard(nudge: nudge, navigationManager: navigationManager)
                                }
                            }
                        }

                        // RECENT CAPTURES
                        if !recentCaptures.isEmpty {
                            VStack(spacing: 10) {
                                SectionLabel("Recent captures")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ScrollViewReader { proxy in
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            withAnimation {
                                                if !recentCaptures.isEmpty {
                                                    proxy.scrollTo(recentCaptures[0].id, anchor: .leading)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(LinkMeColors.s500)
                                                .frame(width: 32, height: 32)
                                                .background(LinkMeColors.surface)
                                                .cornerRadius(8)
                                                .border(LinkMeColors.s200, width: 1)
                                        }

                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(recentCaptures, id: \.id) { person in
                                                    Button(action: {
                                                        navigationManager.navigationPath.append(person)
                                                    }) {
                                                        Card(padding: 12) {
                                                            VStack(spacing: 8) {
                                                                Avatar(name: person.name, size: 48, tone: person.tone)

                                                                VStack(spacing: 2) {
                                                                    Text(person.name.split(separator: " ").first.map(String.init) ?? person.name)
                                                                        .font(.system(size: 13, weight: .semibold, design: .default))
                                                                        .foregroundColor(LinkMeColors.ink)
                                                                        .lineLimit(1)

                                                                    Text(person.company)
                                                                        .font(.system(size: 11, design: .default))
                                                                        .foregroundColor(LinkMeColors.s500)
                                                                        .lineLimit(1)
                                                                }
                                                            }
                                                            .frame(width: 84)
                                                            .frame(maxHeight: .infinity, alignment: .top)
                                                        }
                                                        .frame(width: 108)
                                                        .id(person.id)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 0)
                                        }

                                        Button(action: {
                                            withAnimation {
                                                if let last = recentCaptures.last {
                                                    proxy.scrollTo(last.id, anchor: .trailing)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(LinkMeColors.s500)
                                                .frame(width: 32, height: 32)
                                                .background(LinkMeColors.surface)
                                                .cornerRadius(8)
                                                .border(LinkMeColors.s200, width: 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                }
            }
        }
        .onAppear {
            loadRecentCaptures()
            calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
        .onChange(of: navigationManager.navigationPath.count) { _, _ in
            loadRecentCaptures()
        }
    }
}

// MARK: - TopBar
struct TopBar: View {
    let appState: AppState
    let navigationManager: NavigationManager
    @Binding var selectedTab: Int
    @State private var threadCount = 3

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let firstName = appState.currentUser?.name.split(separator: " ").first.map(String.init) ?? "there"

        let timeGreeting: String
        switch hour {
        case 5..<12:
            timeGreeting = "Good morning"
        case 12..<17:
            timeGreeting = "Good afternoon"
        case 17..<21:
            timeGreeting = "Good evening"
        default:
            timeGreeting = "Good night"
        }

        return "\(timeGreeting), \(firstName)"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.system(size: 13.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .fontWeight(.medium)

                Text("Today")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .tracking(-0.02)
                    .foregroundColor(LinkMeColors.ink)
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: {
                    selectedTab = 1
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.s500)
                        .frame(width: 32, height: 32)
                        .background(LinkMeColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                        )
                }

                Button(action: {
                    selectedTab = 3
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.s500)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )

                        Circle()
                            .fill(LinkMeColors.t500)
                            .frame(width: 17, height: 17)
                            .overlay(
                                Text(String(threadCount))
                                    .font(.system(size: 10.5, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }
}

// MARK: - Up Next Card
struct EmptyCalendarDayCard: View {
    var body: some View {
        Card(padding: 18) {
            HStack(spacing: 14) {
                EventIcon(kind: .coffee, size: 56, highlighted: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("No more events today")
                        .font(.system(size: 19, weight: .semibold, design: .default))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)

                    Text("When your calendar has a meeting, lunch, coffee, or group event, it will appear here with the right briefing context.")
                        .font(.system(size: 14.5, design: .default))
                        .foregroundColor(LinkMeColors.s600)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
        }
    }
}

struct ConnectCalendarCard: View {
    let action: () -> Void

    var body: some View {
        Card(padding: 0) {
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        EventIcon(kind: .meeting, size: 56, highlighted: true)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Connect your calendar")
                                .font(.system(size: 19, weight: .semibold, design: .default))
                                .tracking(-0.02)
                                .foregroundColor(LinkMeColors.ink)
                        }

                        Spacer()

                        Chip("iPhone", tone: .teal, icon: "calendar")
                    }

                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LinkMeColors.t700)

                            Text("What you will get")
                                .font(.system(size: 11.5, weight: .semibold, design: .default))
                                .tracking(0.02)
                                .textCase(.uppercase)
                                .foregroundColor(LinkMeColors.t700)

                            Spacer()
                        }

                        Text("Before a meeting, lunch, coffee, or group event, LinkMe will show who is involved, where it is, and the one thing worth remembering.")
                            .font(.system(size: 14.5, design: .default))
                            .foregroundColor(LinkMeColors.s700)
                            .lineHeight(1.5)
                    }
                    .padding(14)
                    .background(LinkMeColors.t50)
                    .cornerRadius(14)
                }
                .padding(18)

                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Connect calendar")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(LinkMeColors.ink)
                }
            }
        }
    }
}

struct UpNextCard: View {
    let event: TodayCalendarEvent
    let navigationManager: NavigationManager

    var body: some View {
        Card(padding: 0) {
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        Avatar(name: event.displayName, size: 56, ring: true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.displayName)
                                .font(.system(size: 19, weight: .semibold, design: .default))
                                .tracking(-0.02)
                                .foregroundColor(LinkMeColors.ink)

                            Text(event.subtitle)
                                .font(.system(size: 13.5, design: .default))
                                .foregroundColor(LinkMeColors.s500)
                        }

                        Spacer()

                        Chip(event.channel, tone: .slate, icon: event.kind.icon)
                    }

                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LinkMeColors.t700)

                            Text("The one thing to remember")
                                .font(.system(size: 11.5, weight: .semibold, design: .default))
                                .tracking(0.02)
                                .textCase(.uppercase)
                                .foregroundColor(LinkMeColors.t700)

                            Spacer()
                        }

                        Text(event.briefing)
                            .font(.system(size: 14.5, design: .default))
                            .foregroundColor(LinkMeColors.s700)
                            .lineHeight(1.5)
                    }
                    .padding(14)
                    .background(LinkMeColors.t50)
                    .cornerRadius(14)
                }
                .padding(18)

                Button(action: {
                    if let person = event.person {
                        navigationManager.openBriefing(person)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Brief me before \(event.formattedTime)")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(LinkMeColors.ink)
                }
                .disabled(event.person == nil)
            }
        }
    }
}

// MARK: - Later Today Item
struct LaterTodayItem: View {
    let event: TodayCalendarEvent
    var isPreview: Bool = false

    var body: some View {
        HStack(spacing: 13) {
            Text(event.formattedTime)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s600)
                .frame(width: 52, alignment: .trailing)

            Rectangle()
                .fill(LinkMeColors.s200)
                .frame(width: 1, height: 30)

            if let person = event.person, !event.isGroupEvent {
                Avatar(name: person.name, size: 34)
            } else {
                EventIcon(kind: event.kind, size: 34, highlighted: false)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)

                Text(isPreview ? previewDetail : event.location)
                    .font(.system(size: 12.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if !isPreview {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LinkMeColors.s300)
            }
        }
        .padding(13)
    }

    private var previewDetail: String {
        if event.isGroupEvent {
            return "\(event.attendeeCount) people · \(event.location)"
        }
        return event.location
    }
}

struct EventIcon: View {
    let kind: TodayCalendarEvent.EventKind
    let size: CGFloat
    let highlighted: Bool

    var body: some View {
        Image(systemName: kind.icon)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundColor(LinkMeColors.t600)
            .frame(width: size, height: size, alignment: .center)
            .background(highlighted ? LinkMeColors.t100 : LinkMeColors.t50)
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.32)
                    .strokeBorder(LinkMeColors.t200, lineWidth: highlighted ? 2 : 1)
            )
            .cornerRadius(size * 0.32)
    }
}

// MARK: - Needs You Card
struct NeedsYouCard: View {
    let nudge: NudgeModel
    let navigationManager: NavigationManager
    @State private var person: PersonModel?

    var body: some View {
        Button(action: {
            if let person = person {
                navigationManager.openFollowup(person, nudge: nudge)
            }
        }) {
            Card(padding: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Avatar(name: person?.name ?? nudge.personId, size: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(nudge.title)
                            .font(.system(size: 14.5, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.ink)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(nudge.detail)
                            .font(.system(size: 12.5, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Chip(nudge.cta, tone: .ink)
                }
            }
        }
        .onAppear {
            person = MockDataManager.mockPeople.first { $0.id == nudge.personId }
        }
    }
}

extension Text {
    func lineHeight(_ lineHeight: CGFloat) -> some View {
        self
    }
}

#Preview {
    let appState = AppState()
    let defaultCard = CardModel(
        firstName: "Marcus",
        lastName: "Chen",
        email: "marcus@meridian.com",
        role: "General Partner",
        company: "Meridian Ventures",
        isDefault: true
    )
    appState.currentUser = UserModel(
        firstName: "Marcus",
        lastName: "Chen",
        email: "marcus@meridian.com",
        role: "General Partner",
        company: "Meridian Ventures",
        cards: [defaultCard]
    )
    @State var selectedTab = 0
    return TodayView(navigationManager: NavigationManager(), appState: appState, selectedTab: $selectedTab)
}

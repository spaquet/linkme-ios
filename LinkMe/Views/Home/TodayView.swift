import SwiftUI

struct TodayView: View {
    let navigationManager: NavigationManager
    let appState: AppState
    @Binding var selectedTab: Int
    @State private var people: [PersonModel] = MockDataManager.mockPeople
    @State private var nudges: [NudgeModel] = MockDataManager.mockNudges

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
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                SectionLabel("Up next · 3:00 PM")
                                Spacer()
                                OnDeviceChip()
                            }

                            UpNextCard(navigationManager: navigationManager)
                        }

                        // LATER TODAY
                        VStack(spacing: 10) {
                            SectionLabel("Later today")

                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    ForEach(0..<2, id: \.self) { i in
                                        LaterTodayItem(
                                            time: i == 0 ? "4:30 PM" : "6:00 PM",
                                            title: i == 0 ? "Team sync" : "Dinner with Alex",
                                            location: i == 0 ? "Conference room" : "Downtown",
                                            personName: i == 0 ? nil : "Alex Rivera"
                                        )

                                        if i == 0 {
                                            Divider(inset: 68)
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

                        // RECENT CAPTURES (only show if 3+ contacts)
                        if people.count >= 3 {
                            VStack(spacing: 10) {
                                SectionLabel("Recent captures")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ScrollViewReader { proxy in
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            withAnimation {
                                                if !people.isEmpty {
                                                    proxy.scrollTo(people[0].id, anchor: .leading)
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
                                                ForEach(people.prefix(6), id: \.id) { person in
                                                    Button(action: {
                                                        navigationManager.navigationPath.append(person)
                                                    }) {
                                                        Card(padding: 12) {
                                                            VStack(spacing: 8) {
                                                                Avatar(name: person.name, size: 48, tone: person.tone)

                                                                VStack(spacing: 2) {
                                                                    Text(person.name.split(separator: " ")[0])
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
                                                if people.count >= 6 {
                                                    proxy.scrollTo(people[5].id, anchor: .trailing)
                                                } else if !people.isEmpty {
                                                    proxy.scrollTo(people[people.count - 1].id, anchor: .trailing)
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.s600)
                        .frame(width: 40, height: 40)
                        .background(LinkMeColors.surface)
                        .cornerRadius(12)
                        .border(LinkMeColors.s200, width: 1)
                }

                Button(action: {
                    selectedTab = 3
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 40, height: 40)
                            .background(LinkMeColors.surface)
                            .cornerRadius(12)
                            .border(LinkMeColors.s200, width: 1)

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
struct UpNextCard: View {
    let navigationManager: NavigationManager

    var body: some View {
        Card(padding: 0) {
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        Avatar(name: "Marcus Chen", size: 56, ring: true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Marcus Chen")
                                .font(.system(size: 19, weight: .semibold, design: .default))
                                .tracking(-0.02)
                                .foregroundColor(LinkMeColors.ink)

                            Text("General Partner · Meridian Ventures")
                                .font(.system(size: 13.5, design: .default))
                                .foregroundColor(LinkMeColors.s500)
                        }

                        Spacer()

                        Chip("Zoom", tone: .slate)
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

                        Text("He owes you the data-infra memo, and you offered the Naomi intro. Lead with the fund close — announced Tuesday.")
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
                    if let firstPerson = MockDataManager.mockPeople.first {
                        navigationManager.openBriefing(firstPerson)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Brief me before 3:00")
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

// MARK: - Later Today Item
struct LaterTodayItem: View {
    let time: String
    let title: String
    let location: String
    let personName: String?

    var body: some View {
        HStack(spacing: 13) {
            Text(time)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s600)
                .frame(width: 52, alignment: .trailing)

            Rectangle()
                .fill(LinkMeColors.s200)
                .frame(width: 1, height: 30)

            if let personName = personName {
                Avatar(name: personName, size: 34)
            } else {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LinkMeColors.t600)
                    .frame(width: 34, height: 34, alignment: .center)
                    .background(LinkMeColors.t50)
                    .cornerRadius(11)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)

                Text(location)
                    .font(.system(size: 12.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(LinkMeColors.s300)
        }
        .padding(13)
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

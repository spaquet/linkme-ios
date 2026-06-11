import SwiftUI

struct PersonDetailView: View {
    let person: PersonModel
    let navigationManager: NavigationManager
    @State private var threads: [ThreadModel] = []
    @State private var sharedPeople: [PersonModel] = []

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button and actions
                HStack(spacing: 12) {
                    Button(action: {
                        navigationManager.navigationPath.removeLast()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.surface)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.surface)
                            .cornerRadius(8)
                    }

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.surface)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .navigationBarBackButtonHidden(true)

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Color.clear
                                .id("top")
                                .frame(height: 0)

                            // Identity section
                            VStack(spacing: 10) {
                            Avatar(name: person.name, size: 84, ring: true)

                            VStack(spacing: 2) {
                                Text(person.name)
                                    .font(.system(size: 25, weight: .semibold, design: .default))
                                    .tracking(-0.025)
                                    .foregroundColor(LinkMeColors.ink)

                                Text("\(person.role) · \(person.company)")
                                    .font(.system(size: 15, design: .default))
                                    .foregroundColor(LinkMeColors.s500)
                            }

                            if !person.tags.isEmpty {
                                HStack(spacing: 6) {
                                    Spacer()
                                    ForEach(person.tags, id: \.self) { tag in
                                        Chip(tag, tone: .slate)
                                    }
                                    Spacer()
                                }
                            }

                            HStack(spacing: 16) {
                                HStack(spacing: 5) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(LinkMeColors.s400)
                                    Text(person.location)
                                        .font(.system(size: 12.5, design: .default))
                                }

                                HStack(spacing: 5) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(LinkMeColors.s400)
                                    Text(person.met)
                                        .font(.system(size: 12.5, design: .default))
                                }
                            }
                            .foregroundColor(LinkMeColors.s500)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 18)

                        // Quick actions
                        VStack(spacing: 9) {
                            HStack(spacing: 9) {
                                QuickActionButton(
                                    icon: "wand.and.stars",
                                    label: "Brief me",
                                    primary: true,
                                    action: {}
                                )
                                QuickActionButton(
                                    icon: "paperplane.fill",
                                    label: "Message",
                                    primary: false,
                                    action: {}
                                )
                                QuickActionButton(
                                    icon: "square.and.arrow.up",
                                    label: "Share back",
                                    primary: false,
                                    action: {}
                                )
                                QuickActionButton(
                                    icon: "person.2.fill",
                                    label: "Intro",
                                    primary: false,
                                    action: {}
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)

                        // Live context
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                SectionLabel("Live context")
                                Spacer()
                                OnDeviceChip()
                            }

                            VStack(alignment: .leading, spacing: 0) {
                                Text(person.context)
                                    .font(.system(size: 15, design: .default))
                                    .foregroundColor(LinkMeColors.s700)
                                    .lineSpacing(2)
                                    .padding(16)
                            }
                            .background(LinkMeColors.t50)
                            .border(LinkMeColors.t200, width: 1)
                            .cornerRadius(LinkMeLayout.cardRadius)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)

                        // Open threads
                        if !person.openThreads.isEmpty {
                            VStack(alignment: .leading, spacing: 9) {
                                HStack(spacing: 8) {
                                    SectionLabel("Open threads")
                                    Text("\(person.openThreads.count)")
                                        .font(.system(size: 11, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                }

                                Card(padding: 0) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(person.openThreads.indices, id: \.self) { index in
                                            VStack(alignment: .leading, spacing: 0) {
                                                HStack(alignment: .top, spacing: 11) {
                                                    Circle()
                                                        .fill(LinkMeColors.amber500)
                                                        .frame(width: 8, height: 8)
                                                        .padding(.top, 6)

                                                    Text(person.openThreads[index])
                                                        .font(.system(size: 14.5, design: .default))
                                                        .lineSpacing(1)
                                                        .foregroundColor(LinkMeColors.s700)

                                                    Spacer()
                                                }
                                                .padding(.vertical, 13)
                                                .padding(.horizontal, 16)

                                                if index < person.openThreads.count - 1 {
                                                    Divider()
                                                        .padding(.leading, 35)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }

                        // Talking points
                        if !person.talkingPoints.isEmpty {
                            VStack(alignment: .leading, spacing: 9) {
                                SectionLabel("Talking points")

                                VStack(spacing: 8) {
                                    ForEach(person.talkingPoints.indices, id: \.self) { index in
                                        Card {
                                            HStack(alignment: .top, spacing: 11) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(LinkMeColors.t50)
                                                        .frame(width: 24, height: 24)

                                                    Text("\(index + 1)")
                                                        .font(.system(size: 12, weight: .bold, design: .default))
                                                        .foregroundColor(LinkMeColors.t700)
                                                }
                                                .frame(width: 24, height: 24)

                                                Text(person.talkingPoints[index])
                                                    .font(.system(size: 14.5, design: .default))
                                                    .lineSpacing(1)
                                                    .foregroundColor(LinkMeColors.s700)

                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }

                        // Personal detail
                        if !person.personal.isEmpty {
                            VStack(alignment: .leading, spacing: 9) {
                                SectionLabel("Personal detail")

                                Card {
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 9)
                                                .fill(LinkMeColors.s100)
                                                .frame(width: 30, height: 30)

                                            Image(systemName: "star")
                                                .font(.system(size: 16, weight: .regular))
                                                .foregroundColor(LinkMeColors.s500)
                                        }
                                        .frame(width: 30, height: 30)

                                        Text(person.personal)
                                            .font(.system(size: 14.5, design: .default))
                                            .lineSpacing(1)
                                            .foregroundColor(LinkMeColors.s700)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }

                        // Shared connections
                        if !sharedPeople.isEmpty {
                            VStack(alignment: .leading, spacing: 9) {
                                HStack(spacing: 8) {
                                    SectionLabel("Shared connections")
                                    Text("\(sharedPeople.count)")
                                        .font(.system(size: 11, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                }

                                Card(padding: 14) {
                                    VStack(spacing: 0) {
                                        ForEach(sharedPeople.indices, id: \.self) { index in
                                            VStack(spacing: 0) {
                                                Button(action: {
                                                    navigationManager.navigationPath.append(sharedPeople[index])
                                                }) {
                                                    HStack(alignment: .center, spacing: 11) {
                                                        Avatar(name: sharedPeople[index].name, size: 36)

                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(sharedPeople[index].name)
                                                                .font(.system(size: 14.5, weight: .semibold, design: .default))
                                                                .foregroundColor(LinkMeColors.ink)

                                                            Text("\(sharedPeople[index].role) · \(sharedPeople[index].company)")
                                                                .font(.system(size: 12, design: .default))
                                                                .foregroundColor(LinkMeColors.s500)
                                                        }

                                                        Spacer()

                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 16, weight: .semibold))
                                                            .foregroundColor(LinkMeColors.s300)
                                                    }
                                                    .padding(.vertical, 9)
                                                }

                                                if index < sharedPeople.count - 1 {
                                                    Divider()
                                                        .padding(.leading, 47)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }

                        // Timeline
                        if !person.timeline.isEmpty {
                            VStack(alignment: .leading, spacing: 9) {
                                SectionLabel("Relationship timeline")

                                VStack(alignment: .leading, spacing: 14) {
                                    ForEach(person.timeline.indices, id: \.self) { index in
                                        HStack(alignment: .top, spacing: 13) {
                                            TimelineDot(kind: person.timeline[index].kind)

                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack {
                                                    Text(person.timeline[index].label)
                                                        .font(.system(size: 14.5, weight: .semibold, design: .default))
                                                        .foregroundColor(LinkMeColors.ink)

                                                    Spacer()

                                                    Text(person.timeline[index].date)
                                                        .font(.system(size: 12, design: .default))
                                                        .foregroundColor(LinkMeColors.s400)
                                                }

                                                if let detail = person.timeline[index].detail {
                                                    Text(detail)
                                                        .font(.system(size: 13, design: .default))
                                                        .lineSpacing(1)
                                                        .foregroundColor(LinkMeColors.s500)
                                                }
                                            }

                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 0)
                            .padding(.bottom, LinkMeLayout.homeInset)
                        }
                    }
                    .onAppear {
                        scrollProxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            threads = MockDataManager.getThreadsForPerson(person.id)
            let shared = person.shared.compactMap { name in
                MockDataManager.mockPeople.first { $0.name == name }
            }
            sharedPeople = shared
        }
    }
}

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .month, .year], from: date, to: now)

        if let days = components.day, days == 0 {
            return "Today"
        } else if let days = components.day, days == 1 {
            return "Yesterday"
        } else if let days = components.day, days < 7 {
            return "\(days) days ago"
        } else if let weeks = components.day, weeks < 28 {
            let weekCount = weeks / 7
            return "\(weekCount)w ago"
        } else if let months = components.month, months > 0 {
            return "\(months)mo ago"
        } else if let years = components.year, years > 0 {
            return "\(years)y ago"
        }
        return ""
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let label: String
    let primary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(label)
                    .font(.system(size: 11.5, weight: .semibold, design: .default))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .foregroundColor(primary ? .white : LinkMeColors.s700)
            .background(primary ? LinkMeColors.ink : LinkMeColors.surface)
            .border(primary ? LinkMeColors.ink : LinkMeColors.s200, width: 1)
            .cornerRadius(16)
        }
    }
}

// MARK: - Timeline Dot
struct TimelineDot: View {
    let kind: String

    private var dotColor: Color {
        switch kind {
        case "capture": return LinkMeColors.t500
        case "meet": return LinkMeColors.ink
        default: return LinkMeColors.s400
        }
    }

    private var bgColor: Color {
        switch kind {
        case "capture": return LinkMeColors.t50
        default: return LinkMeColors.s100
        }
    }

    private var borderColor: Color {
        switch kind {
        case "capture": return LinkMeColors.t200
        default: return LinkMeColors.s200
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(bgColor)
                .border(borderColor, width: 1)
                .frame(width: 30, height: 30)

            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dotColor)
        }
        .frame(width: 30, height: 30)
    }

    private var iconName: String {
        switch kind {
        case "capture": return "mic.fill"
        case "meet": return "person.2.fill"
        default: return "bubbles.and.sparkles"
        }
    }
}


#Preview {
    PersonDetailView(person: MockDataManager.mockPeople[0], navigationManager: NavigationManager())
}

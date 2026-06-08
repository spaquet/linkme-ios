import SwiftUI

struct TodayView: View {
    @State private var people: [PersonModel] = [
        PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"),
        PersonModel(id: "2", name: "Sarah Johnson", company: "Acme Corp", role: "VP Product"),
        PersonModel(id: "3", name: "Alex Rivera", company: "TechStart", role: "Founder & CEO"),
    ]

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                TopBar()
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

                            UpNextCard()
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
                                Button("All threads") {
                                    // Navigate to threads
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(LinkMeColors.t700)
                            }

                            VStack(spacing: 10) {
                                NeedsYouItem(
                                    personName: "Marcus Chen",
                                    message: "Waiting on your data-infra memo"
                                )
                                NeedsYouItem(
                                    personName: "Sarah Johnson",
                                    message: "Promised product demo feedback"
                                )
                            }
                        }

                        // RECENT PEOPLE
                        VStack(spacing: 10) {
                            SectionLabel("Recent")

                            HStack(spacing: 12) {
                                ForEach(people.prefix(3), id: \.id) { person in
                                    VStack(spacing: 8) {
                                        Avatar(name: person.name, size: 56)

                                        Text(person.name.split(separator: " ")[0])
                                            .font(.system(size: 13, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.ink)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
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
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good afternoon, Marcus")
                    .font(.system(size: 13.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .fontWeight(.medium)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.s600)
                }

                ZStack(alignment: .topTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                    }

                    Circle()
                        .fill(LinkMeColors.t500)
                        .frame(width: 17, height: 17)
                        .overlay(
                            Text("3")
                                .font(.system(size: 10.5, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        )
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}

// MARK: - Up Next Card
struct UpNextCard: View {
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

                Button(action: {}) {
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

// MARK: - Needs You Item
struct NeedsYouItem: View {
    let personName: String
    let message: String

    var body: some View {
        Card(padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Avatar(name: personName, size: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(personName)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.ink)

                        Text(message)
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .lineLimit(1)
                    }

                    Spacer()
                }
            }
        }
    }
}

extension Text {
    func lineHeight(_ lineHeight: CGFloat) -> some View {
        self
    }
}

#Preview {
    TodayView()
}

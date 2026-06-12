import SwiftUI

struct BriefingView: View {
    let person: PersonModel
    @State private var briefingSummary = "Lead with the fund close. He owes you the data-infra memo; you offered an intro."
    @State private var openThreads: [ThreadModel] = []
    @State private var sharedConnections: [PersonModel] = []
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.t700)
                    }

                    Spacer()

                    Text("Brief")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.ink)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Person card
                        Card(padding: 0) {
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Avatar(name: person.name, size: 52)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(person.name)
                                            .font(.system(size: 17, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.ink)

                                        Text("\(person.role) · \(person.company)")
                                            .font(.system(size: 13, design: .default))
                                            .foregroundColor(LinkMeColors.s500)
                                    }

                                    Spacer()
                                }
                                .padding(16)

                                Divider(inset: 0)

                                // The one thing to remember
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(LinkMeColors.t700)

                                        Text("The one thing to remember")
                                            .font(.system(size: 11.5, weight: .semibold, design: .default))
                                            .tracking(0.02)
                                            .textCase(.uppercase)
                                            .foregroundColor(LinkMeColors.t700)
                                    }

                                    Text(briefingSummary)
                                        .font(.system(size: 14.5, design: .default))
                                        .foregroundColor(LinkMeColors.s700)
                                        .lineHeight(1.5)
                                }
                                .padding(16)
                                .background(LinkMeColors.t50)
                            }
                        }

                        // Open threads
                        if !openThreads.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionLabel("What you promised")

                                VStack(spacing: 10) {
                                    ForEach(openThreads, id: \.id) { thread in
                                        ThreadItemView(thread: thread)
                                    }
                                }
                            }
                        }

                        // Shared connections
                        if !sharedConnections.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionLabel("Shared connections")

                                HStack(spacing: 12) {
                                    ForEach(sharedConnections.prefix(3), id: \.id) { connection in
                                        VStack(spacing: 8) {
                                            Avatar(name: connection.name, size: 44)

                                            Text(connection.name.split(separator: " ")[0])
                                                .font(.system(size: 12, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.ink)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }

                                    if sharedConnections.count > 3 {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(LinkMeColors.s100)

                                                Text("+\(sharedConnections.count - 3)")
                                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                                    .foregroundColor(LinkMeColors.s600)
                                            }
                                            .frame(width: 44, height: 44)

                                            Text("More")
                                                .font(.system(size: 12, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.s500)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }

                        // Actions
                        VStack(spacing: 10) {
                            PrimaryButton("Add note", tone: .teal) {
                                // Open capture
                            }

                            Button(action: {}) {
                                Text("View full profile")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(LinkMeColors.s100)
                                    .cornerRadius(LinkMeLayout.cornerRadius)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .padding(.bottom, LinkMeLayout.homeInset)
                }
            }
        }
        .onAppear {
            loadBriefingData()
        }
    }

    private func loadBriefingData() {
        openThreads = MockDataManager.getThreadsForPerson(person.id)
        sharedConnections = MockDataManager.getSharedConnections(for: person.id)
    }
}

// MARK: - Thread Item
struct ThreadItemView: View {
    let thread: ThreadModel

    var body: some View {
        Card(padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LinkMeColors.t500)

                Text(thread.prompt)
                    .font(.system(size: 14, design: .default))
                    .foregroundColor(LinkMeColors.s700)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LinkMeColors.s300)
            }
        }
    }
}


#Preview {
    BriefingView(person: PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"))
}

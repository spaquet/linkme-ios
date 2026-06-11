import SwiftUI

struct ThreadsView: View {
    let navigationManager: NavigationManager
    @State private var nudges: [NudgeModel] = MockDataManager.mockNudges

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // TopBar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Threads")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .tracking(-0.03)
                        .foregroundColor(LinkMeColors.ink)

                    Text("Proactive nudges & open follow-ups")
                        .font(.system(size: 13.5, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Content
                ScrollView {
                    VStack(spacing: 22) {
                        // PROACTIVE NUDGES
                        VStack(spacing: 11) {
                            HStack(spacing: 7) {
                                SectionLabel("Proactive nudges")

                                HStack(spacing: 5) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(LinkMeColors.t700)

                                    Text("On-device AI")
                                        .font(.system(size: 11, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.t700)
                                }
                                .frame(height: 22)
                                .padding(.horizontal, 8)
                                .background(LinkMeColors.t50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .strokeBorder(LinkMeColors.t200, lineWidth: 1)
                                )
                                .cornerRadius(999)

                                Spacer()
                            }

                            VStack(spacing: 11) {
                                ForEach(nudges, id: \.id) { nudge in
                                    NudgeCard(nudge: nudge, navigationManager: navigationManager)
                                }
                            }
                        }

                        // Privacy note
                        HStack(spacing: 8) {
                            Image(systemName: "lock")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(LinkMeColors.t600)

                            Text("Nudges are generated on your device. Nothing was sent anywhere.")
                                .font(.system(size: 12.5, design: .default))
                                .foregroundColor(LinkMeColors.s400)

                            Spacer()
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

// MARK: - Nudge Card
struct NudgeCard: View {
    let nudge: NudgeModel
    let navigationManager: NavigationManager
    @State private var person: PersonModel?

    var body: some View {
        let chipTone: Chip.ChipTone = {
            switch nudge.kind {
            case "signal": return .teal
            case "promise": return .amber
            default: return .slate
            }
        }()

        let chipLabel: String = {
            switch nudge.kind {
            case "signal": return "Live signal"
            case "promise": return "You promised"
            default: return "Reciprocity"
            }
        }()

        Card(padding: 16) {
            VStack(spacing: 13) {
                HStack(spacing: 13) {
                    Avatar(name: person?.name ?? nudge.personId, size: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(person?.name ?? "Person")
                                .font(.system(size: 15.5, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.ink)

                            Chip(chipLabel, tone: chipTone)
                                .frame(height: 21)
                        }

                        Text(nudge.detail)
                            .font(.system(size: 13.5, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .lineHeight(1.5)
                    }

                    Spacer()
                }

                HStack(spacing: 9) {
                    Button(action: {
                        if let person = person {
                            navigationManager.openPersonDetail(person)
                        }
                    }) {
                        HStack(spacing: 7) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 16, weight: .semibold))

                            Text(nudge.cta)
                                .font(.system(size: 14.5, weight: .semibold, design: .default))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(13)
                    }

                    Button(action: {
                        if let person = person {
                            navigationManager.openPersonDetail(person)
                        }
                    }) {
                        Image(systemName: "person")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 42, height: 42)
                            .background(LinkMeColors.surface)
                            .cornerRadius(13)
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .onAppear {
            person = MockDataManager.mockPeople.first { $0.id == nudge.personId }
        }
    }
}

#Preview {
    ThreadsView(navigationManager: NavigationManager())
}

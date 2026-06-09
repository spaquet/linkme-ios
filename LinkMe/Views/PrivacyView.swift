import SwiftUI

struct PrivacyView: View {
    @State private var cloudEnrichment = false
    @State private var lifeSignals = true
    @State private var calendar = true
    @State private var contacts = true
    @State private var siri = true

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy")
                            .font(.system(size: 28, weight: .semibold, design: .default))
                            .tracking(-0.02)
                            .foregroundColor(LinkMeColors.ink)

                        Text("You can see exactly what stays on device")
                            .font(.system(size: 13, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .padding(.top, LinkMeLayout.statusBarHeight - 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // Hero section
                        VStack(spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 0) {
                                        Image(systemName: "shield.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(LinkMeColors.t400)
                                            .frame(width: 46, height: 46)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(14)

                                        Spacer()
                                    }

                                    Text("Your relationship brain lives on this device.")
                                        .font(.system(size: 21, weight: .semibold, design: .default))
                                        .tracking(-0.02)
                                        .foregroundColor(.white)
                                        .lineHeight(1.25)

                                    Text("Capture, transcription, briefings and nudges all run on-device with Apple's on-device models. Nothing leaves unless you turn on a specific switch below.")
                                        .font(.system(size: 13.5, design: .default))
                                        .foregroundColor(Color.white.opacity(0.66))
                                        .lineHeight(1.55)

                                    HStack(spacing: 18) {
                                        StatItem(number: "18", label: "people")
                                        StatItem(number: "46", label: "captures")
                                        StatItem(number: "0", label: "left this device", highlight: true)
                                    }
                                }

                                Spacer()
                            }
                        }
                        .padding(22)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    LinkMeColors.ink,
                                    Color(#colorLiteral(red: 0.08, green: 0.19, blue: 0.23, alpha: 1))
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(22)

                        // What runs on device
                        VStack(spacing: 10) {
                            SectionLabel("What runs on device")

                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    PrivacyRow(
                                        icon: "mic",
                                        title: "Voice capture & transcription",
                                        detail: "Speech-to-text and extraction never leave your iPhone.",
                                        isToggled: .constant(true),
                                        isLocked: true
                                    )

                                    Divider(inset: 63)

                                    PrivacyRow(
                                        icon: "sparkles",
                                        title: "Briefings & nudges",
                                        detail: "Summaries and talking points are generated locally.",
                                        isToggled: .constant(true),
                                        isLocked: true
                                    )
                                }
                            }
                        }

                        // What needs your permission
                        VStack(spacing: 10) {
                            SectionLabel("What needs your permission")

                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    PrivacyRow(
                                        icon: "link",
                                        title: "Cloud enrichment",
                                        detail: "Look up public company & news context. Sends only a name + company.",
                                        isToggled: $cloudEnrichment,
                                        isLocked: false
                                    )

                                    Divider(inset: 63)

                                    PrivacyRow(
                                        icon: "star.fill",
                                        title: "Life & deal signals",
                                        detail: "Watch public sources for fundraises, role changes and press.",
                                        isToggled: $lifeSignals,
                                        isLocked: false
                                    )

                                    Divider(inset: 63)

                                    PrivacyRow(
                                        icon: "calendar",
                                        title: "Calendar",
                                        detail: "Read upcoming events to time your briefings.",
                                        isToggled: $calendar,
                                        isLocked: false
                                    )

                                    Divider(inset: 63)

                                    PrivacyRow(
                                        icon: "person.2",
                                        title: "Contacts",
                                        detail: "Match captures to people you already know.",
                                        isToggled: $contacts,
                                        isLocked: false
                                    )

                                    Divider(inset: 63)

                                    PrivacyRow(
                                        icon: "waveform.circle.fill",
                                        title: "Siri & App Intents",
                                        detail: "\"Hey Siri, brief me on Marcus.\" Requests are handled on device.",
                                        isToggled: $siri,
                                        isLocked: false
                                    )
                                }
                            }
                        }

                        VStack(spacing: 4) {
                            Text("We never build aggregate data products from your network.")
                                .font(.system(size: 12.5, design: .default))
                                .foregroundColor(LinkMeColors.s400)

                            Text("Your graph is yours.")
                                .font(.system(size: 12.5, design: .default))
                                .foregroundColor(LinkMeColors.s400)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                }
            }
        }
    }
}

struct StatItem: View {
    let number: String
    let label: String
    let highlight: Bool

    init(number: String, label: String, highlight: Bool = false) {
        self.number = number
        self.label = label
        self.highlight = highlight
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(highlight ? LinkMeColors.t400 : .white)

            Text(label)
                .font(.system(size: 11.5, design: .default))
                .foregroundColor(Color.white.opacity(0.6))
        }
    }
}

struct PrivacyRow: View {
    let icon: String
    let title: String
    let detail: String
    @Binding var isToggled: Bool
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(LinkMeColors.t700)
                .frame(width: 34, height: 34)
                .background(LinkMeColors.t50)
                .cornerRadius(11)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)

                    if isLocked {
                        Text("Always")
                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.t700)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(LinkMeColors.t50)
                            .cornerRadius(999)
                    }

                    Spacer()
                }

                Text(detail)
                    .font(.system(size: 12.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineHeight(1.45)
            }

            Toggle("", isOn: $isToggled)
                .disabled(isLocked)
                .opacity(isLocked ? 0.85 : 1)
        }
        .padding(14)
    }
}

#Preview {
    PrivacyView()
}

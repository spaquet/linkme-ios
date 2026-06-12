import SwiftUI

struct PrivacyView: View {
    let appState: AppState
    @StateObject private var contactSync = ContactSyncManager.shared
    @State private var cloudEnrichment = false
    @State private var lifeSignals = false
    @State private var calendar = true
    @State private var siri = false
    @State private var showResetConfirmation = false

    private var contactsBinding: Binding<Bool> {
        Binding(
            get: { contactSync.isEnabled },
            set: { contactSync.setEnabled($0) }
        )
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)

                    Text("You can see exactly what stays on device")
                        .font(.system(size: 13.5, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Hero section
                        VStack(spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 0) {
                                        Image(systemName: "checkmark.shield")
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
                                        StatItem(number: "0", label: "left this device")
                                    }
                                }

                                Spacer()
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )

                        // What needs your permission
                        VStack(alignment: .leading, spacing: 10) {
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
                                        detail: "Bidirectional sync with your iPhone contacts.",
                                        isToggled: contactsBinding,
                                        isLocked: false
                                    )

                                    if contactSync.isEnabled {
                                        ContactSyncStatusView(state: contactSync.state, stats: contactSync.stats)
                                            .padding(.horizontal, 14)
                                            .padding(.bottom, 14)
                                    }

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

                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Reset app for testing")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .foregroundColor(.white)
                            .background(LinkMeColors.s500)
                            .cornerRadius(12)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                }
            }
        }
        .alert("Reset App?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.reset()
            }
        } message: {
            Text("This will clear all data and return you to onboarding.")
        }
        .onAppear {
            contactSync.refreshIfEnabled()
        }
    }
}

struct ContactSyncStatusView: View {
    let state: ContactSyncState
    let stats: ContactSyncStats

    private var statusColor: Color {
        switch state {
        case .synced: LinkMeColors.t600
        case .syncing: LinkMeColors.s600
        case .failed, .denied: Color.red.opacity(0.75)
        default: LinkMeColors.s500
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if state == .syncing {
                    ProgressView()
                        .scaleEffect(0.72)
                } else {
                    Image(systemName: state == .synced ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(statusColor)
                }

                Text(state.label)
                    .font(.system(size: 12.5, weight: .semibold, design: .default))
                    .foregroundColor(statusColor)

                Spacer()

                if let lastSyncedAt = stats.lastSyncedAt {
                    Text(lastSyncedAt, style: .time)
                        .font(.system(size: 11.5, design: .default))
                        .foregroundColor(LinkMeColors.s400)
                }
            }

            HStack(spacing: 10) {
                SyncMetric(value: "\(stats.total)", label: "fetched")
                SyncMetric(value: "\(stats.stored)", label: "in People")
                SyncMetric(value: "\(stats.imported)", label: "new")
                SyncMetric(value: "\(stats.updated)", label: "updated")
            }
        }
        .padding(12)
        .background(LinkMeColors.t50.opacity(0.55))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinkMeColors.t100, lineWidth: 1)
        )
    }
}

struct SyncMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.ink)

            Text(label)
                .font(.system(size: 10.5, design: .default))
                .foregroundColor(LinkMeColors.s500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatItem: View {
    let number: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(number)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)

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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(LinkMeColors.t600)
                    .frame(width: 40, height: 40)
                    .background(LinkMeColors.t50)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(LinkMeColors.t200, lineWidth: 1.5)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.ink)

                        if isLocked {
                            Text("Always")
                                .font(.system(size: 11, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.t700)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(LinkMeColors.t100)
                                .cornerRadius(999)
                        }

                        Spacer()
                    }

                    Text(detail)
                        .font(.system(size: 13.5, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                        .lineHeight(1.4)
                }

                CustomToggle(isOn: $isToggled, isLocked: isLocked)
                    .frame(width: 50, height: 30)
            }
        }
        .padding(14)
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool
    let isLocked: Bool

    var body: some View {
        Button(action: {
            if !isLocked {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.toggle()
                }
            }
        }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 999)
                    .fill(isOn ? LinkMeColors.t500 : LinkMeColors.s300)

                Circle()
                    .fill(.white)
                    .padding(3)
            }
        }
        .disabled(isLocked)
        .opacity(isLocked ? 0.85 : 1)
    }
}

#Preview {
    PrivacyView(appState: AppState())
}

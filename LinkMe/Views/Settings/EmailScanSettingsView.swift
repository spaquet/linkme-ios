import SwiftUI

/// Email scanning settings and manual trigger UI.
struct EmailScanSettingsView: View {
    @State private var manager = EmailScanManager.shared
    @State private var tokenManager = OAuthTokenManager.shared
    @State private var showResults = false
    @State private var isConnectingGmail = false
    @State private var gmailError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav header
                HStack(spacing: 10) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.s500)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Email scanning")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)

                    Text("Detect new connections from your inbox")
                        .font(.system(size: 13.5, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Active signals
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Signals")

                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    // Scan action row — routes to connected provider
                                    Button(action: {
                                        Task {
                                            if tokenManager.isGmailConnected {
                                                await manager.scanGmail()
                                            } else {
                                                await manager.scanAppleMail()
                                            }
                                        }
                                    }) {
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "person.badge.plus")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(manager.isScanning ? LinkMeColors.s400 : LinkMeColors.t600)
                                                .frame(width: 40, height: 40)
                                                .background(manager.isScanning ? LinkMeColors.s100 : LinkMeColors.t50)
                                                .cornerRadius(14)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(manager.isScanning ? LinkMeColors.s200 : LinkMeColors.t200, lineWidth: 1.5)
                                                )

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("LinkedIn connections")
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(manager.isScanning ? LinkMeColors.s400 : LinkMeColors.ink)

                                                if let lastScan = manager.stats.lastScannedAt {
                                                    Text("Last scan \(lastScan.formatted(.relative(presentation: .named)))")
                                                        .font(.system(size: 13.5, design: .default))
                                                        .foregroundColor(LinkMeColors.s500)
                                                } else {
                                                    Text("Never scanned")
                                                        .font(.system(size: 13.5, design: .default))
                                                        .foregroundColor(LinkMeColors.s500)
                                                }
                                            }

                                            Spacer()

                                            if manager.isScanning {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            } else {
                                                scanStateBadge
                                            }
                                        }
                                        .padding(14)
                                    }
                                    .disabled(manager.isScanning || !tokenManager.isGmailConnected)

                                    if !manager.pendingLinkedInConnections.isEmpty {
                                        Divider(inset: 63)

                                        Button(action: { showResults = true }) {
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: "tray.full")
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
                                                    Text("Pending connections")
                                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                                        .foregroundColor(LinkMeColors.ink)

                                                    Text("\(manager.pendingLinkedInConnections.count) waiting to be added")
                                                        .font(.system(size: 13.5, design: .default))
                                                        .foregroundColor(LinkMeColors.s500)
                                                }

                                                Spacer()

                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(LinkMeColors.s300)
                                            }
                                            .padding(14)
                                        }
                                    }
                                }
                            }
                        }

                        // Last scan stats
                        if manager.stats.lastScannedAt != nil {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionLabel("Last scan")

                                Card(padding: 0) {
                                    VStack(spacing: 0) {
                                        ScanStatRow(label: "Emails processed", value: "\(manager.stats.scanned)")
                                        Divider(inset: 16)
                                        ScanStatRow(label: "Connections found", value: "\(manager.stats.linkedInFound)")
                                        Divider(inset: 16)
                                        ScanStatRow(label: "People created", value: "\(manager.stats.personsCreated)")
                                        Divider(inset: 16)
                                        ScanStatRow(label: "Threads created", value: "\(manager.stats.threadsCreated)")
                                    }
                                }
                            }
                        }

                        // Providers
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Providers")

                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    ComingSoonProviderRow(
                                        icon: AnyView(
                                            Image(systemName: "envelope")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(LinkMeColors.s400)
                                        ),
                                        label: "Apple Mail"
                                    )

                                    Divider(inset: 63)

                                    // Gmail — live OAuth
                                    GmailProviderRow(
                                        tokenManager: tokenManager,
                                        isConnecting: isConnectingGmail,
                                        isScanning: manager.isScanning,
                                        onConnect: {
                                            Task {
                                                isConnectingGmail = true
                                                gmailError = nil
                                                do {
                                                    try await GmailAuthService.shared.authenticate()
                                                } catch OAuthError.authCancelled {
                                                    // user cancelled — silent
                                                } catch {
                                                    gmailError = error.localizedDescription
                                                }
                                                isConnectingGmail = false
                                            }
                                        },
                                        onScan: {
                                            Task { await manager.scanGmail() }
                                        },
                                        onDisconnect: {
                                            tokenManager.disconnectGmail()
                                        }
                                    )

                                    Divider(inset: 63)

                                    ComingSoonProviderRow(
                                        icon: AnyView(
                                            Image("ms-outlook")
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .foregroundColor(LinkMeColors.s400)
                                                .frame(width: 20, height: 20)
                                        ),
                                        label: "Outlook"
                                    )
                                }
                            }

                            if let error = gmailError {
                                Text(error)
                                    .font(.system(size: 12, design: .default))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .padding(.bottom, LinkMeLayout.tabBarHeight + 18)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showResults) {
            LinkedInConnectionsView()
        }
    }

    @ViewBuilder
    private var scanStateBadge: some View {
        switch manager.state {
        case .scanning:
            Text("Scanning")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.t700)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(LinkMeColors.t100)
                .cornerRadius(999)
        case .idle:
            if tokenManager.isGmailConnected {
                Text("Active")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.t700)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(LinkMeColors.t100)
                    .cornerRadius(999)
            } else {
                Text("No provider")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(LinkMeColors.s100)
                    .cornerRadius(999)
            }
        case .failed:
            Text("Error")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.75))
                .cornerRadius(999)
        default:
            EmptyView()
        }
    }
}

/// Single stat row in the scan results card.
private struct ScanStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, design: .default))
                .foregroundColor(LinkMeColors.s600)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

/// Gmail provider row with connect/scan/disconnect actions.
private struct GmailProviderRow: View {
    let tokenManager: OAuthTokenManager
    let isConnecting: Bool
    let isScanning: Bool
    let onConnect: () -> Void
    let onScan: () -> Void
    let onDisconnect: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image("gmail")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .frame(width: 40, height: 40)
                .background(tokenManager.isGmailConnected ? LinkMeColors.t50 : LinkMeColors.s100)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(tokenManager.isGmailConnected ? LinkMeColors.t200 : LinkMeColors.s200, lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Gmail")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(tokenManager.isGmailConnected ? LinkMeColors.ink : LinkMeColors.s500)

                if let email = tokenManager.gmailEmail {
                    Text(email)
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(LinkMeColors.s400)
                } else {
                    Text("Read-only")
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(LinkMeColors.s400)
                }
            }

            Spacer()

            if tokenManager.isGmailConnected {
                Menu {
                    Button {
                        onScan()
                    } label: {
                        Label("Scan now", systemImage: "arrow.clockwise")
                    }
                    .disabled(isScanning)

                    Divider()

                    Button(role: .destructive) {
                        onDisconnect()
                    } label: {
                        Label("Disconnect", systemImage: "xmark.circle")
                    }
                } label: {
                    if isScanning {
                        ProgressView()
                            .scaleEffect(0.75)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.s500)
                            .frame(width: 32, height: 32)
                            .background(LinkMeColors.s100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            } else {
                Button(action: onConnect) {
                    if isConnecting {
                        ProgressView()
                            .scaleEffect(0.75)
                            .frame(width: 68, height: 28)
                    } else {
                        Text("Connect")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.t700)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(LinkMeColors.t50)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(LinkMeColors.t200, lineWidth: 1.5)
                            )
                    }
                }
                .disabled(isConnecting)
            }
        }
        .padding(14)
    }
}

/// Coming-soon provider row with generic icon slot.
private struct ComingSoonProviderRow: View {
    let icon: AnyView
    let label: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            icon
                .frame(width: 40, height: 40)
                .background(LinkMeColors.s100)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(LinkMeColors.s200, lineWidth: 1.5)
                )

            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s500)

            Spacer()

            Text("Coming soon")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s500)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(LinkMeColors.s100)
                .cornerRadius(999)
        }
        .padding(14)
    }
}

/// List of pending LinkedIn connections for user to claim or dismiss.
struct LinkedInConnectionsView: View {
    @State private var manager = EmailScanManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinkMeColors.canvas.ignoresSafeArea()

                if manager.pendingLinkedInConnections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.clock")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(LinkMeColors.s300)

                        Text("No pending connections")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            Card(padding: 0) {
                                VStack(spacing: 0) {
                                    ForEach(Array(manager.pendingLinkedInConnections.enumerated()), id: \.element.id) { index, connection in
                                        LinkedInConnectionRow(connection: connection)

                                        if index < manager.pendingLinkedInConnections.count - 1 {
                                            Divider(inset: 63)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    }
                }
            }
            .navigationTitle("LinkedIn connections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

/// Single row for a pending LinkedIn connection.
struct LinkedInConnectionRow: View {
    let connection: LinkedInConnection

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinkMeColors.t50)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(PersonModel.computeInitials(connection.name))
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.t600)
                )
                .overlay(Circle().stroke(LinkMeColors.t200, lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(connection.name)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)

                if let headline = connection.headline {
                    Text(headline)
                        .font(.system(size: 13, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button("Add") {
                // TODO: Navigate to person or trigger claim flow
            }
            .font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundColor(LinkMeColors.t600)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(LinkMeColors.t50)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(LinkMeColors.t200, lineWidth: 1.5)
            )
        }
        .padding(14)
    }
}

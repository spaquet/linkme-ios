import SwiftUI

/// Email scanning settings and manual trigger UI.
struct EmailScanSettingsView: View {
    @State private var manager = EmailScanManager.shared
    @State private var showResults = false

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple Mail")
                            .font(.body)
                        Text("Scans for LinkedIn connections")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    statusBadge
                }

                if let lastScan = manager.stats.lastScannedAt {
                    Text("Last scan: \(lastScan.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Email Providers")
            }

            Section {
                Button(action: { Task { await manager.scanAppleMail() } }) {
                    HStack {
                        Label("Scan Now", systemImage: "arrow.clockwise")
                        Spacer()
                        if manager.isScanning {
                            ProgressView().scaleEffect(0.8)
                        }
                    }
                }
                .disabled(manager.isScanning)

                if !manager.pendingLinkedInConnections.isEmpty {
                    Button("View \(manager.pendingLinkedInConnections.count) LinkedIn connections") {
                        showResults = true
                    }
                }
            } header: {
                Text("Actions")
            }

            if manager.stats.lastScannedAt != nil {
                Section {
                    LabeledContent("Emails scanned", value: "\(manager.stats.scanned)")
                    LabeledContent("Connections found", value: "\(manager.stats.linkedInFound)")
                    LabeledContent("People created", value: "\(manager.stats.personsCreated)")
                    LabeledContent("Threads created", value: "\(manager.stats.threadsCreated)")
                } header: {
                    Text("Last Scan Stats")
                }
            }

            Section {
                HStack {
                    Label("Gmail", systemImage: "envelope")
                    Spacer()
                    Text("Coming in Phase 4")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("Outlook", systemImage: "envelope")
                    Spacer()
                    Text("Coming in Phase 4")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Other Providers")
            } footer: {
                Text("Gmail and Outlook support coming soon.")
            }
        }
        .navigationTitle("Email Scanning")
        .sheet(isPresented: $showResults) {
            LinkedInConnectionsView()
        }
    }

    @ViewBuilder
    var statusBadge: some View {
        switch manager.state {
        case .scanning:
            Label("Scanning", systemImage: "arrow.clockwise")
                .font(.caption)
                .foregroundStyle(.teal)
        case .idle:
            Text("Active")
                .font(.caption)
                .foregroundStyle(.green)
        case .failed(let msg):
            Text("Error: \(msg)")
                .font(.caption)
                .foregroundStyle(.red)
        default:
            EmptyView()
        }
    }
}

/// List of pending LinkedIn connections for user to claim or dismiss.
struct LinkedInConnectionsView: View {
    @State private var manager = EmailScanManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(manager.pendingLinkedInConnections) { connection in
                LinkedInConnectionRow(connection: connection)
            }
            .navigationTitle("LinkedIn Connections")
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
                .fill(Color.teal.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(PersonModel.computeInitials(connection.name))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.teal)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(connection.name)
                    .font(.body.weight(.semibold))
                if let headline = connection.headline {
                    Text(headline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Add") {
                // TODO: Navigate to person or trigger claim flow
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
}

import SwiftUI

struct PersonDetailView: View {
    let person: PersonModel
    @State private var notes: [NoteModel] = []
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

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Person Header Card
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(colors: [LinkMeColors.t500, LinkMeColors.t700]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 52)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 14) {
                                Avatar(name: person.name, size: 56, ring: true)
                                    .offset(y: -24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.system(size: 19, weight: .semibold, design: .default))
                                        .tracking(-0.02)
                                        .foregroundColor(LinkMeColors.ink)

                                    Text("\(person.role) · \(person.company)")
                                        .font(.system(size: 13, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }

                                Spacer()
                            }

                            // Action buttons
                            HStack(spacing: 8) {
                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Brief")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .foregroundColor(.white)
                                    .background(LinkMeColors.t500)
                                    .cornerRadius(LinkMeLayout.cornerRadius)
                                }

                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Share")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .foregroundColor(LinkMeColors.ink)
                                    .background(LinkMeColors.s100)
                                    .cornerRadius(LinkMeLayout.cornerRadius)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Timeline
                ScrollView {
                    VStack(spacing: 16) {
                        if notes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(LinkMeColors.s300)

                                Text("No notes yet")
                                    .font(.system(size: 15, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s500)

                                Text("Capture your first note after meeting")
                                    .font(.system(size: 13, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            VStack(spacing: 12) {
                                SectionLabel("Timeline")

                                ForEach(notes, id: \.id) { note in
                                    TimelineItemView(note: note)
                                }
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
            let dbNotes = DatabaseManager.shared.fetchNotesForPerson(person.id)
            notes = dbNotes.isEmpty ? MockDataManager.getNotesForPerson(person.id) : dbNotes
        }
    }
}

// MARK: - Timeline Item
struct TimelineItemView: View {
    let note: NoteModel

    var body: some View {
        Card(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        if note.isFollowUp {
                            Chip("Follow-up", tone: .amber, icon: "arrow.uturn.right")
                        } else {
                            Chip("Note", tone: .slate)
                        }

                        Text(note.text)
                            .font(.system(size: 14, design: .default))
                            .foregroundColor(LinkMeColors.s700)
                            .lineLimit(3)
                            .padding(.top, 2)
                    }

                    Spacer()
                }

                HStack {
                    Text(formatDate(note.createdAt))
                        .font(.system(size: 12, design: .default))
                        .foregroundColor(LinkMeColors.s400)

                    Spacer()

                    OnDeviceChip()
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    PersonDetailView(person: PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"))
}

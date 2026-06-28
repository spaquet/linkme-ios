/// Draft and send a follow-up message to a person.
///
/// AI-generated message with tone selection (Warm, Brief, Formal), channel selection, and send/schedule options.
/// Triggered from briefing view or nudges. Marked the follow-up as "sent" in person's thread.
struct FollowupView: View {
    /// Person to follow up with.
    let person: PersonModel

    /// Optional nudge context (what type of follow-up).
    let nudge: NudgeModel?

    /// Callback when user dismisses sheet.
    let onDismiss: () -> Void

    @State private var selectedTone: String = "Warm"
    @State private var draftText: String = ""
    @State private var selectedChannel: String = "Messages"
    @State private var isRegenerating: Bool = false
    @State private var isSent: Bool = false

    private let tones = ["Warm", "Brief", "Formal"]

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Button(action: onDismiss) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(LinkMeColors.s600)
                            }

                            Spacer()

                            Button(action: regenerateTone) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(LinkMeColors.s600)
                                    .frame(width: 38, height: 38)
                                    .background(LinkMeColors.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                            }
                        }

                        Text("Follow-up")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.ink)
                    }
                    .padding(16)
                    .padding(.top, 12)

                    Divider()
                        .foregroundColor(LinkMeColors.s200)
                }

                // Content
                ScrollView {
                    VStack(spacing: 14) {
                        // Recipient card
                        Card(padding: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                Avatar(name: person.name, size: 44, tone: person.tone)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(person.name)
                                        .font(.system(size: 15.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .multilineTextAlignment(.leading)

                                    Text("\(person.role) · \(person.company)")
                                        .font(.system(size: 12.5, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Spacer()

                                HStack(spacing: 6) {
                                    ForEach(["Messages", "Email"], id: \.self) { channel in
                                        Button(action: { selectedChannel = channel }) {
                                            Text(channel)
                                                .font(.system(size: 12.5, weight: .semibold, design: .default))
                                                .lineLimit(1)
                                                .frame(height: 30)
                                                .padding(.horizontal, 6)
                                                .background(selectedChannel == channel ? LinkMeColors.ink : LinkMeColors.surface)
                                                .foregroundColor(selectedChannel == channel ? .white : LinkMeColors.s600)
                                                .cornerRadius(999)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 999)
                                                        .strokeBorder(
                                                            selectedChannel == channel ? LinkMeColors.ink : LinkMeColors.s200,
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                        }

                        // Nudge context
                        if let nudge = nudge {
                            HStack(spacing: 9) {
                                Image(systemName: "bell")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(LinkMeColors.amber600)

                                Text(nudge.detail)
                                    .font(.system(size: 13, design: .default))
                                    .foregroundColor(LinkMeColors.s700)
                                    .lineHeight(1.45)

                                Spacer()
                            }
                            .padding(13)
                            .background(LinkMeColors.amber50)
                            .border(LinkMeColors.amber100, width: 1)
                            .cornerRadius(13)
                        }

                        // Tone selector
                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                SectionLabel("Tone")

                                HStack(spacing: 5) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(LinkMeColors.t700)

                                    Text("Drafted on device")
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

                            HStack(spacing: 8) {
                                ForEach(tones, id: \.self) { tone in
                                    Button(action: {
                                        selectTone(tone)
                                    }) {
                                        Text(tone)
                                            .font(.system(size: 13.5, weight: .semibold, design: .default))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 38)
                                            .background(selectedTone == tone ? LinkMeColors.t50 : LinkMeColors.surface)
                                            .foregroundColor(selectedTone == tone ? LinkMeColors.t700 : LinkMeColors.s600)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(
                                                        selectedTone == tone ? LinkMeColors.t200 : LinkMeColors.s200,
                                                        lineWidth: 1.5
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Draft textarea
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $draftText)
                                    .font(.system(size: 15.5, design: .default))
                                    .foregroundColor(LinkMeColors.s700)
                                    .scrollContentBackground(.hidden)
                                    .padding(18)
                                    .frame(minHeight: 200)
                                    .background(LinkMeColors.surface)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1.5)
                                    )

                                if isRegenerating {
                                    ZStack(alignment: .center) {
                                        LinkMeColors.surface
                                            .opacity(0.95)
                                            .cornerRadius(18)

                                        HStack(spacing: 10) {
                                            ProgressView()
                                                .tint(LinkMeColors.t700)

                                            Text("Rewriting, \(selectedTone.lowercased())…")
                                                .font(.system(size: 13.5, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.t700)
                                        }
                                    }
                                }
                            }

                            HStack(spacing: 8) {
                                Button(action: {}) {
                                    HStack(spacing: 7) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .semibold))

                                        Text("Insert a detail")
                                            .font(.system(size: 13.5, weight: .semibold, design: .default))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .foregroundColor(LinkMeColors.s600)
                                    .background(LinkMeColors.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                                }

                                Button(action: regenerateTone) {
                                    HStack(spacing: 7) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16, weight: .semibold))

                                        Text("Regenerate")
                                            .font(.system(size: 13.5, weight: .semibold, design: .default))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .foregroundColor(LinkMeColors.s600)
                                    .background(LinkMeColors.surface)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                    .padding(16)
                    .padding(.vertical, 18)
                }

                // Footer
                VStack(spacing: 0) {
                    Divider()
                        .foregroundColor(LinkMeColors.s200)

                    HStack(spacing: 12) {
                        Text("Sends from your \(selectedChannel). Nothing auto-sends.")
                            .font(.system(size: 12.5, design: .default))
                            .foregroundColor(LinkMeColors.s500)

                        Spacer()

                        Button(action: send) {
                            HStack(spacing: 7) {
                                Image(systemName: "paperplane")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Send")
                                    .font(.system(size: 14.5, weight: .semibold, design: .default))
                            }
                            .frame(width: 160)
                            .frame(height: 42)
                            .foregroundColor(.white)
                            .background(LinkMeColors.t600)
                            .cornerRadius(13)
                        }
                    }
                    .padding(12)
                    .padding(.bottom, LinkMeLayout.homeInset)
                    .background(LinkMeColors.surface)
                }
            }
        }
        .onAppear {
            draftText = person.followup
        }
        .sheet(isPresented: $isSent) {
            SentSuccessSheet(person: person, onDismiss: {
                isSent = false
                onDismiss()
            })
        }
    }

    private func selectTone(_ tone: String) {
        selectedTone = tone
        isRegenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            updateDraftForTone(tone)
            isRegenerating = false
        }
    }

    private func regenerateTone() {
        selectTone(selectedTone)
    }

    private func updateDraftForTone(_ tone: String) {
        let firstName = person.name.split(separator: " ").first.map(String.init) ?? ""
        let firstOpenThread = person.openThreads.first ?? ""

        switch tone {
        case "Warm":
            draftText = person.followup
        case "Brief":
            let threadText = firstOpenThread.isEmpty ? "" : (firstOpenThread.replacingOccurrences(of: "^You ", with: "I'll ", options: .regularExpression).replacingOccurrences(of: "^Owes you", with: "Looking forward to") + ". ")
            draftText = "\(firstName) — great connecting. \(threadText)Talk soon."
        case "Formal":
            let threadPreview = firstOpenThread.isEmpty ? "" : "I'll follow up shortly on what we discussed. "
            draftText = """
            Hi \(firstName),

            Thank you for the time today — I appreciated the conversation. \(threadPreview)Please let me know if there's anything useful I can send ahead.

            Best,
            Your Name
            """
        default:
            draftText = person.followup
        }
    }

    private func send() {
        isSent = true
    }
}

struct SentSuccessSheet: View {
    let person: PersonModel
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                    }

                    Text("Follow-up")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)

                    Spacer()
                }
                .padding(16)
                .padding(.top, 12)

                Divider()
                    .foregroundColor(LinkMeColors.s200)

                // Content
                ScrollView {
                    VStack(spacing: 18) {
                        VStack(spacing: 18) {
                            Circle()
                                .fill(LinkMeColors.t50)
                                .frame(width: 74, height: 74)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 36, weight: .semibold))
                                        .foregroundColor(LinkMeColors.t600)
                                )

                            VStack(spacing: 6) {
                                Text("Sent to \(person.name.split(separator: " ")[0])")
                                    .font(.system(size: 21, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.ink)

                                VStack(spacing: 3) {
                                    Text("Logged to your timeline with \(person.name.split(separator: " ")[0]).")
                                        .font(.system(size: 14, design: .default))
                                        .foregroundColor(LinkMeColors.s500)

                                    Text("The relationship just compounded.")
                                        .font(.system(size: 14, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }
                            }
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)

                        Card(padding: 14) {
                            HStack(spacing: 12) {
                                Avatar(name: person.name, size: 40, tone: person.tone)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Send your card too?")
                                        .font(.system(size: 13.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.ink)

                                    Text("Let \(person.name.split(separator: " ")[0]) remember you back.")
                                        .font(.system(size: 12.5, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }

                                Spacer()

                                Chip("Share back", tone: .ink)
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                        }

                        Button(action: onDismiss) {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .foregroundColor(.white)
                                .background(LinkMeColors.ink)
                                .cornerRadius(13)
                        }
                    }
                    .padding(24)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    let person = MockDataManager.mockPeople[0]
    let nudge = MockDataManager.mockNudges[0]
    FollowupView(person: person, nudge: nudge, onDismiss: {})
}

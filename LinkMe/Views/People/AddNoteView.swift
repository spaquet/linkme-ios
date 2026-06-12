import SwiftUI
import Combine

struct AddNoteView: View {
    let person: PersonModel
    @Binding var isPresented: Bool
    @State private var speechManager = SpeechRecognitionManager()
    @State private var phase: AddNotePhase = .selectMode
    @State private var seconds = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var noteText = ""
    @State private var tagsText = ""

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 38, height: 38)
                            .background(LinkMeColors.surface)
                            .cornerRadius(10)
                            .border(LinkMeColors.s200, width: 1)
                    }

                    Spacer()

                    Text("Add Note")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)

                    Spacer()

                    Rectangle()
                        .fill(.clear)
                        .frame(width: 38, height: 38)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.top, LinkMeLayout.statusBarHeight - 20)

                // Content based on phase
                Group {
                    switch phase {
                    case .selectMode:
                        SelectModeView(
                            onVoice: startVoiceNote,
                            onType: { phase = .typing }
                        )

                    case .listening:
                        ListeningPhaseView(
                            seconds: seconds,
                            transcript: speechManager.recognizedText,
                            isRecording: speechManager.isRecording,
                            onStop: stopListening
                        )

                    case .typing:
                        TypingPhaseView(
                            text: $noteText,
                            tagsText: $tagsText,
                            onSave: saveNote
                        )
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            speechManager.requestAuthorization { _ in
                // Continue regardless
            }
        }
        .onDisappear {
            timerTask?.cancel()
            speechManager.cancelRecording()
        }
    }

    private func startVoiceNote() {
        phase = .listening
        seconds = 0
        speechManager.startRecording()

        timerTask = Task {
            while phase == .listening {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                seconds += 1
            }
        }
    }

    private func stopListening() {
        timerTask?.cancel()
        noteText = speechManager.recognizedText
        phase = .typing
    }

    private func saveNote() {
        guard !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let note = NoteModel(
            personId: person.id,
            text: noteText,
            transcription: noteText
        )

        DatabaseManager.shared.insertNote(note)
        isPresented = false
    }
}

enum AddNotePhase: Equatable {
    case selectMode
    case listening
    case typing
}

// MARK: - Select Mode
struct SelectModeView: View {
    let onVoice: () -> Void
    let onType: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 24) {
                    Text("How do you want to add a note?")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        Button(action: onVoice) {
                            HStack(spacing: 14) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(LinkMeColors.t600)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Voice note")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.ink)

                                    Text("Speak your thoughts. AI extracts key points.")
                                        .font(.system(size: 13.5, weight: .regular, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(LinkMeColors.s300)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(LinkMeColors.surface)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )
                        }

                        Button(action: onType) {
                            HStack(spacing: 14) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(LinkMeColors.t600)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Type note")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.ink)

                                    Text("Add notes and tags when voice isn't an option.")
                                        .font(.system(size: 13.5, weight: .regular, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(LinkMeColors.s300)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(LinkMeColors.surface)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

// MARK: - Listening Phase
struct ListeningPhaseView: View {
    let seconds: Int
    let transcript: String
    let isRecording: Bool
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 26) {
                VStack(spacing: 6) {
                    Text(String(format: "0:%02d", seconds))
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(LinkMeColors.t700)

                    Text("Listening…")
                        .font(.system(size: 23, weight: .semibold))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)
                }

                WaveformView(active: isRecording)

                VStack(spacing: 0) {
                    HStack(spacing: 2) {
                        Text(transcript)
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .lineLimit(4)
                            .foregroundColor(LinkMeColors.s600)

                        if isRecording {
                            Rectangle()
                                .fill(LinkMeColors.t500)
                                .frame(width: 2, height: 18)
                                .opacity(0.6)
                        }
                    }
                    .frame(minHeight: 120, alignment: .center)
                    .multilineTextAlignment(.center)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, 22)
            .padding(.vertical, 28)

            VStack(spacing: 14) {
                Button(action: onStop) {
                    ZStack {
                        Circle()
                            .fill(LinkMeColors.ink)

                        RoundedRectangle(cornerRadius: 7)
                            .fill(LinkMeColors.surface)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 72, height: 72)
                    .shadow(color: LinkMeColors.ink.opacity(0.22), radius: 12, y: 12)
                }

                Text("Tap to stop")
                    .font(.system(size: 12.5, weight: .regular, design: .default))
                    .foregroundColor(LinkMeColors.s400)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - Typing Phase
struct TypingPhaseView: View {
    @Binding var text: String
    @Binding var tagsText: String
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 7) {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.t600)

                        Text("Note")
                            .font(.system(size: 11.5, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.t700)

                        Spacer()
                    }

                    TextEditor(text: $text)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                        .padding(12)
                        .background(LinkMeColors.surface)
                        .border(LinkMeColors.s200, width: 1)
                        .cornerRadius(12)
                        .frame(height: 120)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 7) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.t600)

                        Text("Tags")
                            .font(.system(size: 11.5, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.t700)

                        Spacer()
                    }

                    TextField("Add tags separated by commas", text: $tagsText)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                        .padding(12)
                        .background(LinkMeColors.surface)
                        .border(LinkMeColors.s200, width: 1)
                        .cornerRadius(12)
                }

                PrimaryButton("Save note", tone: .teal) {
                    onSave()
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    AddNoteView(
        person: PersonModel(id: "1", name: "Marcus Chen", company: "Meridian Ventures", role: "General Partner"),
        isPresented: .constant(true)
    )
}

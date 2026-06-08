import SwiftUI

struct CaptureView: View {
    @State private var speechManager = SpeechRecognitionManager()
    @State private var aiManager = AIExtractionManager()
    @State private var isShowingResult = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(LinkMeColors.t700)

                    Spacer()

                    Text("New Note")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.ink)

                    Spacer()

                    Button("") {}
                        .disabled(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Content
                if isShowingResult, let data = aiManager.extractedData {
                    ExtractionResultView(data: data, onDone: {
                        dismiss()
                    })
                } else {
                    CaptureContentView(
                        speechManager: speechManager,
                        aiManager: aiManager,
                        isShowingResult: $isShowingResult
                    )
                }

                Spacer()
            }
        }
        .onAppear {
            speechManager.requestAuthorization { authorized in
                if !authorized {
                    errorMessage = "Microphone access denied. Enable in Settings > LinkMe > Microphone"
                    showErrorAlert = true
                }
            }
        }
        .onChange(of: speechManager.error) { oldValue, newValue in
            if let error = newValue {
                errorMessage = error
                showErrorAlert = true
                speechManager.error = nil
            }
        }
        .onChange(of: aiManager.error) { oldValue, newValue in
            if let error = newValue {
                errorMessage = error
                showErrorAlert = true
                aiManager.error = nil
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Capture Content
struct CaptureContentView: View {
    let speechManager: SpeechRecognitionManager
    let aiManager: AIExtractionManager
    @Binding var isShowingResult: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 20) {
                // Waveform animation
                if speechManager.isRecording {
                    HStack(spacing: 4) {
                        ForEach(0..<12, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4)
                                .frame(height: CGFloat([40, 30, 35, 28, 38, 25, 32, 29, 36, 27, 34, 31][i]))
                                .scaleEffect(y: Double.random(in: 0.5...1.0), anchor: .center)
                                .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: speechManager.isRecording)
                        }
                    }
                    .frame(height: 56)
                    .padding(.vertical, 10)
                } else {
                    Text("Tap to speak")
                        .font(.system(size: 15, design: .default))
                        .foregroundColor(LinkMeColors.s400)
                        .frame(height: 56, alignment: .center)
                }

                // Transcription
                if !speechManager.recognizedText.isEmpty {
                    Text(speechManager.recognizedText)
                        .font(.system(size: 16, design: .default))
                        .foregroundColor(LinkMeColors.s700)
                        .lineLimit(4)
                        .padding(.horizontal, 16)
                } else {
                    Text("You just met someone. Speak one sentence about them.")
                        .font(.system(size: 15, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                }
            }

            // Mic button
            Button(action: {
                if speechManager.isRecording {
                    speechManager.stopRecording()
                } else {
                    speechManager.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(speechManager.isRecording ? LinkMeColors.ink : LinearGradient(
                            gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                            startPoint: .init(x: 0, y: 0),
                            endPoint: .init(x: 0.5, y: 0.5)
                        ))

                    if !speechManager.isRecording {
                        Circle()
                            .stroke(LinkMeColors.t400, lineWidth: 2)
                            .padding(5)
                            .opacity(0.5)
                            .scaleEffect(1.4)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: !speechManager.isRecording)
                    }

                    Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 76, height: 76)
            }
            .disabled(aiManager.isExtracting)

            // Extract button
            if !speechManager.recognizedText.isEmpty && !speechManager.isRecording {
                PrimaryButton(
                    aiManager.isExtracting ? "Extracting..." : "Create Note",
                    tone: .teal
                ) {
                    Task {
                        await aiManager.extractFromTranscription(speechManager.recognizedText)
                        withAnimation {
                            isShowingResult = true
                        }
                    }
                }
                .disabled(aiManager.isExtracting)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
    }
}

// MARK: - Extraction Result
struct ExtractionResultView: View {
    let data: ExtractedPersonData
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Card(padding: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 13) {
                        Avatar(name: data.name ?? "Unknown", size: 50)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.name ?? "Name not found")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.ink)

                            if let company = data.company {
                                Text("\(data.role ?? "Role") · \(company)")
                                    .font(.system(size: 13, design: .default))
                                    .foregroundColor(LinkMeColors.s500)
                            }
                        }

                        Spacer()

                        OnDeviceChip()
                    }
                    .padding(16)

                    if let context = data.liveContext {
                        Divider()

                        VStack(alignment: .leading, spacing: 4) {
                            SectionLabel("Live context")
                            Text(context)
                                .font(.system(size: 14, design: .default))
                                .foregroundColor(LinkMeColors.s700)
                                .lineLimit(3)
                        }
                        .padding(13)
                    }
                }
            }

            PrimaryButton("Save Note", tone: .ink) {
                onDone()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
    }
}

#Preview {
    CaptureView()
}

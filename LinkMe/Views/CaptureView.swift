import SwiftUI
import Combine

struct CaptureView: View {
    @State private var speechManager = SpeechRecognitionManager()
    @State private var aiManager = AIExtractionManager()
    @State private var phase: CapturePhase = .idle
    @State private var seconds = 0
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var timerTask: Task<Void, Never>?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s600)
                            .frame(width: 38, height: 38)
                            .background(LinkMeColors.surface)
                            .cornerRadius(10)
                            .border(LinkMeColors.s200, width: 1)
                    }

                    Spacer()

                    if phase == .result {
                        OnDeviceChip("Stayed on this device")
                    } else {
                        OnDeviceChip("Recording on device")
                    }

                    Spacer()

                    // Empty space for balance
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
                    case .idle:
                        EmptyView()

                    case .listening:
                        ListeningPhaseView(
                            seconds: seconds,
                            transcript: speechManager.recognizedText,
                            isRecording: speechManager.isRecording,
                            onStop: stopListening
                        )

                    case .processing:
                        ProcessingPhaseView()

                    case .result:
                        if let data = aiManager.extractedData {
                            ResultPhaseView(
                                data: data,
                                transcript: speechManager.recognizedText,
                                onSave: {
                                    dismiss()
                                }
                            )
                        }

                    case .permissionDenied(let permissionType):
                        PermissionDeniedView(
                            permissionType: permissionType,
                            onDismiss: { dismiss() }
                        )
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            speechManager.requestAuthorization { deniedPermission in
                if let deniedPermission = deniedPermission {
                    phase = .permissionDenied(deniedPermission)
                } else {
                    startListening()
                }
            }
        }
        .onDisappear {
            timerTask?.cancel()
            speechManager.cancelRecording()
        }
        .onChange(of: speechManager.error) { _, newValue in
            if let error = newValue {
                errorMessage = error
                showErrorAlert = true
                speechManager.error = nil
            }
        }
        .onChange(of: aiManager.error) { _, newValue in
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

    private func startListening() {
        phase = .listening
        seconds = 0
        speechManager.startRecording()

        timerTask = Task {
            while phase == .listening {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                seconds += 1
            }
        }
    }

    private func stopListening() {
        timerTask?.cancel()
        phase = .processing

        Task {
            await speechManager.stopRecording()
            await aiManager.extractFromTranscription(speechManager.recognizedText)
            phase = .result
        }
    }
}

enum CapturePhase: Equatable {
    case idle
    case listening
    case processing
    case result
    case permissionDenied(PermissionType)
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
                // Timer
                VStack(spacing: 6) {
                    Text(String(format: "0:%02d", seconds))
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(LinkMeColors.t700)

                    Text("Listening…")
                        .font(.system(size: 23, weight: .semibold))
                        .tracking(-0.02)
                        .foregroundColor(LinkMeColors.ink)
                }

                // Waveform
                WaveformView(active: isRecording)

                // Transcript with cursor
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
                // Stop button
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

                Text("Tap to stop · a 10-second note is all it takes")
                    .font(.system(size: 12.5, weight: .regular, design: .default))
                    .foregroundColor(LinkMeColors.s400)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 28)
        }
    }
}

struct WaveformView: View {
    let active: Bool
    let barCount = 34

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2) * .pi

            HStack(spacing: 4) {
                ForEach(0..<barCount, id: \.self) { i in
                    let mid = abs(CGFloat(i) - CGFloat(barCount) / 2) / (CGFloat(barCount) / 2)
                    let baseHeight = 0.9 - mid * 0.65
                    let maxHeight = 64 * baseHeight + 10
                    let minHeight = maxHeight * 0.35

                    // Wave effect: each bar oscillates based on time and position
                    let waveOffset = sin(phase + CGFloat(i) * 0.2) * 0.5 + 0.5
                    let height = minHeight + (maxHeight - minHeight) * waveOffset

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: height)
                        .opacity(active ? 1 : 0.3)
                }
            }
            .frame(height: 96)
        }
        .padding(.horizontal, 0)
    }
}

// MARK: - Processing Phase
struct ProcessingPhaseView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let rotation = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2) * 180

            VStack(spacing: 22) {
                Spacer()

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(LinkMeColors.t100, lineWidth: 3)
                            .frame(width: 78, height: 78)

                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(LinkMeColors.t500, lineWidth: 3)
                            .frame(width: 78, height: 78)
                            .rotationEffect(.degrees(rotation - 90))

                        Image(systemName: "sparkles")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(LinkMeColors.t600)
                    }

                    VStack(spacing: 6) {
                        Text("Structuring the person…")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(LinkMeColors.ink)

                        Text("Apple's on-device model is turning your note\ninto a record. This never leaves your iPhone.")
                            .font(.system(size: 13.5, weight: .regular, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - Result Phase
struct ResultPhaseView: View {
    let data: ExtractedPersonData
    let transcript: String
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.t600)

                    Text("Drafted on device · review & save")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.t700)

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)

                Card(padding: 0) {
                    VStack(spacing: 0) {
                        // Identity
                        HStack(spacing: 14) {
                            Avatar(
                                name: data.name ?? "Unknown",
                                size: 56,
                                tone: "teal"
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(data.name ?? "Name not found")
                                    .font(.system(size: 20, weight: .semibold))
                                    .tracking(-0.02)
                                    .foregroundColor(LinkMeColors.ink)

                                Text("\(data.role ?? "Unknown") · \(data.company ?? "Unknown")")
                                    .font(.system(size: 13.5, weight: .regular, design: .default))
                                    .foregroundColor(LinkMeColors.s500)

                                HStack(spacing: 6) {
                                    Chip("Founder", tone: .teal)
                                    Chip("Healthtech", tone: .teal)
                                    Chip("Seed", tone: .teal)
                                }
                            }

                            Spacer()
                        }
                        .padding(18)

                        Divider()

                        VStack(alignment: .leading, spacing: 13) {
                            ExtractFieldView(
                                icon: "building.2",
                                label: "Live context",
                                text: data.liveContext ?? "No context extracted"
                            )

                            Divider()
                                .padding(.vertical, 0)

                            ExtractFieldView(
                                icon: "arrowshape.forward.fill",
                                label: "Follow-up",
                                text: data.followUp ?? "No follow-up found"
                            )

                            Divider()
                                .padding(.vertical, 0)

                            ExtractFieldView(
                                icon: "heart.fill",
                                label: "Personal detail",
                                text: data.personalDetail ?? "No personal details"
                            )
                        }
                        .padding(18)
                    }
                }

                // Original transcript
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 7) {
                        Image(systemName: "mic")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LinkMeColors.s400)

                        Text("From your \(transcript.split(separator: " ").count)-second note")
                            .font(.system(size: 11.5, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.s400)
                    }

                    Text("\"\(transcript)\"")
                        .font(.system(size: 13.5, weight: .regular, design: .default))
                        .foregroundColor(LinkMeColors.s500)
                        .italic()
                        .lineSpacing(2)
                        .padding(14)
                        .background(LinkMeColors.s50)
                        .border(LinkMeColors.s200, width: 1)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 18)

                HStack(spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.t700)
                            .frame(width: 52, height: 44)
                            .background(LinkMeColors.surface)
                            .border(LinkMeColors.s200, width: 1)
                            .cornerRadius(10)
                    }

                    PrimaryButton("Save to graph", tone: .teal, action: onSave)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 0)
        }
    }
}

struct ExtractFieldView: View {
    let icon: String
    let label: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(LinkMeColors.t700)
                .frame(width: 30, height: 30)
                .background(LinkMeColors.t50)
                .border(LinkMeColors.t200, width: 1)
                .cornerRadius(9)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(label)
                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.s400)

                    Spacer()

                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.s300)
                }

                Text(text)
                    .font(.system(size: 14.5, weight: .regular, design: .default))
                    .foregroundColor(LinkMeColors.s700)
                    .lineSpacing(1)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 13)
    }
}

// MARK: - Permission Denied
struct PermissionDeniedView: View {
    let permissionType: PermissionType
    let onDismiss: () -> Void

    var icon: String {
        switch permissionType {
        case .microphone:
            "mic.slash"
        case .speechRecognition:
            "waveform"
        }
    }

    var title: String {
        switch permissionType {
        case .microphone:
            "Microphone Access Needed"
        case .speechRecognition:
            "Speech Recognition Access Needed"
        }
    }

    var description: String {
        switch permissionType {
        case .microphone:
            "LinkMe needs access to your microphone to capture voice notes. Enable it in Settings to get started."
        case .speechRecognition:
            "LinkMe needs access to Speech Recognition to transcribe your notes. Enable it in Settings to continue."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinkMeColors.s100)
                            .frame(width: 90, height: 90)

                        Image(systemName: icon)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(LinkMeColors.s500)
                    }

                    VStack(spacing: 10) {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .tracking(-0.02)
                            .foregroundColor(LinkMeColors.ink)

                        Text(description)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 30)
                .padding(.vertical, 40)

                VStack(spacing: 12) {
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Open Settings")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LinkMeColors.t600)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: onDismiss) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(LinkMeColors.t700)
                            .background(LinkMeColors.s100)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
        }
    }

    private func openSettings() {
        guard let settingsURL = URL(string: "app-settings://") else { return }
        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    CaptureView()
}

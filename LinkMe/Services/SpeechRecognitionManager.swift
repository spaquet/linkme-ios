import Foundation
import Speech
@preconcurrency import AVFoundation
import CoreMedia

/// Permission type required for speech recording.
enum PermissionType: Equatable {
    /// Microphone recording permission.
    case microphone
    /// Speech recognition permission.
    case speechRecognition
}

/// On-device speech-to-text transcription using Apple Speech framework.
///
/// Records microphone audio, runs speech recognition, and streams back recognized text.
/// Uses the system speech recognizer with configurable locale. Feeds transcripts into ``AIExtractionManager``.
///
/// - Note: Requires microphone permission. Recording happens on-device; no data sent to cloud.
@Observable
@MainActor
class SpeechRecognitionManager {
    /// Whether recording is currently active.
    var isRecording = false

    /// Real-time recognized text (updates as user speaks).
    var recognizedText = ""

    /// Error message if recording or transcription failed.
    var error: String?

    private let audioEngine = AVAudioEngine()
    private var analyzer: SpeechAnalyzer?
    private var transcriber: SpeechTranscriber?
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?
    private var resultTask: Task<Void, Never>?
    private var recordingTask: Task<Void, Never>?
    private var finalizedTranscript = ""
    private var volatileTranscript = ""

    /// Request microphone recording permission.
    ///
    /// - Parameters:
    ///   - completion: Called with nil if granted, or the missing permission type if denied.
    func requestAuthorization(completion: @escaping (PermissionType?) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            guard granted else {
                DispatchQueue.main.async {
                    completion(.microphone)
                }
                return
            }

            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }

    /// Start recording and transcribing from the microphone.
    ///
    /// Initializes speech recognizer, starts audio engine, and begins streaming
    /// recognized text to ``recognizedText``. May request speech model download.
    func startRecording() {
        recognizedText = ""
        error = nil
        finalizedTranscript = ""
        volatileTranscript = ""
        isRecording = true

        recordingTask = Task {
            do {
                try await startAnalyzerRecording()
            } catch {
                handleFailure("Failed to start recording: \(error.localizedDescription)")
            }
        }
    }

    /// Stop recording and finalize the transcript.
    ///
    /// Closes the audio stream, waits for final recognition results, and updates ``recognizedText``.
    /// Call this when the user lifts their finger from the mic button.
    func stopRecording() async {
        guard isRecording || analyzer != nil else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        inputContinuation?.finish()
        inputContinuation = nil
        isRecording = false

        do {
            try await analyzer?.finalizeAndFinishThroughEndOfInput()
            _ = await resultTask?.result
            updateRecognizedText(finalOnly: true)
        } catch {
            handleFailure("Failed to finalize transcript: \(error.localizedDescription)")
        }

        clearAnalyzerReferences()
    }

    /// Cancel recording without finalizing the transcript.
    ///
    /// Clears all state and discards the current recording. Use when user closes
    /// the capture screen without sending.
    func cancelRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        inputContinuation?.finish()
        inputContinuation = nil
        recordingTask?.cancel()
        resultTask?.cancel()
        isRecording = false

        let analyzer = analyzer
        Task {
            await analyzer?.cancelAndFinishNow()
        }

        clearAnalyzerReferences()
    }

    private func startAnalyzerRecording() async throws {
        guard SpeechTranscriber.isAvailable else {
            throw SpeechRecognitionError.transcriberUnavailable
        }

        let supportedLocale = try await selectedTranscriptionLocale()

        let transcriber = SpeechTranscriber(
            locale: supportedLocale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange, .transcriptionConfidence]
        )

        try await ensureModel(for: transcriber)

        let analyzer = SpeechAnalyzer(
            modules: [transcriber],
            options: .init(priority: .userInitiated, modelRetention: .lingering)
        )

        self.transcriber = transcriber
        self.analyzer = analyzer

        resultTask = Task { [weak self, transcriber] in
            do {
                for try await result in transcriber.results {
                    self?.handle(result)
                }
            } catch is CancellationError {
                return
            } catch {
                self?.handleFailure("Speech recognition failed: \(error.localizedDescription)")
            }
        }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        let analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: [transcriber],
            considering: inputFormat
        ) ?? inputFormat

        let inputStream = AsyncStream<AnalyzerInput>.makeStream()
        inputContinuation = inputStream.continuation

        try await analyzer.prepareToAnalyze(in: analyzerFormat)
        try await analyzer.start(inputSequence: inputStream.stream)

        try startAudioEngine(
            inputFormat: inputFormat,
            analyzerFormat: analyzerFormat,
            continuation: inputStream.continuation
        )
    }

    private func selectedTranscriptionLocale() async throws -> Locale {
        let preferredLocales = [
            Locale.autoupdatingCurrent,
            Locale(identifier: "en-US")
        ]

        for locale in preferredLocales {
            if let supportedLocale = await SpeechTranscriber.supportedLocale(equivalentTo: locale) {
                return supportedLocale
            }
        }

        throw SpeechRecognitionError.localeUnsupported(Locale.autoupdatingCurrent.identifier)
    }

    private func ensureModel(for transcriber: SpeechTranscriber) async throws {
        switch await AssetInventory.status(forModules: [transcriber]) {
        case .installed:
            return
        case .supported, .downloading:
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try await request.downloadAndInstall()
            }
        case .unsupported:
            throw SpeechRecognitionError.modelUnsupported
        @unknown default:
            throw SpeechRecognitionError.modelUnsupported
        }
    }

    private func startAudioEngine(
        inputFormat: AVAudioFormat,
        analyzerFormat: AVAudioFormat,
        continuation: AsyncStream<AnalyzerInput>.Continuation
    ) throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let converter = Self.needsConversion(from: inputFormat, to: analyzerFormat)
            ? AVAudioConverter(from: inputFormat, to: analyzerFormat)
            : nil

        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { buffer, _ in
            guard let analyzerBuffer = Self.convert(buffer, to: analyzerFormat, converter: converter) else {
                return
            }

            continuation.yield(AnalyzerInput(buffer: analyzerBuffer))
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func handle(_ result: SpeechTranscriber.Result) {
        let text = String(result.text.characters).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if result.isFinal {
            finalizedTranscript = Self.join(finalizedTranscript, text)
            volatileTranscript = ""
        } else {
            volatileTranscript = text
        }

        updateRecognizedText()
    }

    private func updateRecognizedText(finalOnly: Bool = false) {
        if finalOnly || volatileTranscript.isEmpty {
            recognizedText = finalizedTranscript
        } else {
            recognizedText = Self.join(finalizedTranscript, volatileTranscript)
        }
    }

    private func handleFailure(_ message: String) {
        error = message
        isRecording = false
        clearAnalyzerReferences()
    }

    private func clearAnalyzerReferences() {
        analyzer = nil
        transcriber = nil
        recordingTask = nil
        resultTask = nil
    }

    private nonisolated static func needsConversion(from inputFormat: AVAudioFormat, to outputFormat: AVAudioFormat) -> Bool {
        inputFormat.sampleRate != outputFormat.sampleRate ||
        inputFormat.channelCount != outputFormat.channelCount ||
        inputFormat.commonFormat != outputFormat.commonFormat ||
        inputFormat.isInterleaved != outputFormat.isInterleaved
    }

    private nonisolated static func convert(
        _ buffer: AVAudioPCMBuffer,
        to outputFormat: AVAudioFormat,
        converter: AVAudioConverter?
    ) -> AVAudioPCMBuffer? {
        guard let converter else {
            return buffer
        }

        let ratio = outputFormat.sampleRate / buffer.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
            return nil
        }

        var didProvideInput = false
        var conversionError: NSError?
        let status = converter.convert(to: outputBuffer, error: &conversionError) { _, outStatus in
            if didProvideInput {
                outStatus.pointee = .noDataNow
                return nil
            }

            didProvideInput = true
            outStatus.pointee = .haveData
            return buffer
        }

        switch status {
        case .haveData, .inputRanDry, .endOfStream:
            return outputBuffer
        case .error:
            return nil
        @unknown default:
            return nil
        }
    }

    private nonisolated static func join(_ first: String, _ second: String) -> String {
        guard !first.isEmpty else { return second }
        guard !second.isEmpty else { return first }

        if first.last?.isWhitespace == true || second.first?.isWhitespace == true {
            return first + second
        }

        return first + " " + second
    }
}

private enum SpeechRecognitionError: LocalizedError {
    case transcriberUnavailable
    case localeUnsupported(String)
    case modelUnsupported

    var errorDescription: String? {
        switch self {
        case .transcriberUnavailable:
            "SpeechTranscriber is not available on this device."
        case .localeUnsupported(let locale):
            "Speech transcription is not available for \(locale)."
        case .modelUnsupported:
            "The on-device speech model is not supported for this configuration."
        }
    }
}

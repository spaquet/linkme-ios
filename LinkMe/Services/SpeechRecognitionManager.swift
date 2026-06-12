import Foundation
import Speech
import AVFoundation
import CoreMedia

enum PermissionType: Equatable {
    case microphone
    case speechRecognition
}

@Observable
@MainActor
class SpeechRecognitionManager {
    var isRecording = false
    var recognizedText = ""
    var error: String?

    private let audioEngine = AVAudioEngine()
    private var analyzer: SpeechAnalyzer?
    private var transcriber: SpeechTranscriber?
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?
    private var resultTask: Task<Void, Never>?
    private var recordingTask: Task<Void, Never>?
    private var finalizedTranscript = ""
    private var volatileTranscript = ""
    private let locale = Locale(identifier: "en-US")

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

        guard let supportedLocale = await SpeechTranscriber.supportedLocale(equivalentTo: locale) else {
            throw SpeechRecognitionError.localeUnsupported(locale.identifier)
        }

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

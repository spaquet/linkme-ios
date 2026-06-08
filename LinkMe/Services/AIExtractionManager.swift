import Foundation

struct ExtractedPersonData {
    var name: String?
    var company: String?
    var role: String?
    var liveContext: String?
    var followUp: String?
    var personalDetail: String?
}

@Observable
class AIExtractionManager {
    var isExtracting = false
    var extractedData: ExtractedPersonData?
    var error: String?

    func extractFromTranscription(_ text: String) async {
        isExtracting = true
        defer { isExtracting = false }

        do {
            // Placeholder: Mock extraction logic
            // In production, this would call Foundation Models or cloud API

            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s delay for demo

            let data = mockExtract(text)
            self.extractedData = data
        } catch {
            self.error = "Extraction failed: \(error.localizedDescription)"
        }
    }

    private func mockExtract(_ text: String) -> ExtractedPersonData {
        // Simple heuristic parsing for demo
        let words = text.split(separator: " ").map(String.init)

        var data = ExtractedPersonData()

        // Try to find name (first 2 capitalized words)
        if words.count >= 2,
           words[0].first?.isUppercase ?? false,
           words[1].first?.isUppercase ?? false {
            data.name = "\(words[0]) \(words[1])"
        }

        // Try to find company or role keywords
        if let companyIdx = words.firstIndex(where: { $0.lowercased() == "at" }),
           companyIdx < words.count - 1 {
            data.company = words[companyIdx + 1]
        }

        if let roleIdx = words.firstIndex(where: { $0.lowercased().contains("partner") || $0.lowercased().contains("ceo") || $0.lowercased().contains("founder") }) {
            data.role = words[roleIdx]
        }

        // Extract context (anything after key phrases)
        if let contextIdx = words.firstIndex(where: { $0.lowercased() == "closing" || $0.lowercased() == "launching" }) {
            data.liveContext = words[contextIdx...].joined(separator: " ")
        }

        return data
    }
}

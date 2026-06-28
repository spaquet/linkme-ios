import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Structured person information extracted from a voice transcript.
///
/// Contains fields extracted from a 10-second capture note, such as name, company, role,
/// context, follow-up actions, personal details, and tags. Used as the output of AI extraction.
struct ExtractedPersonData {
    /// Person's full name.
    var name: String?

    /// Company or organization name.
    var company: String?

    /// Job title or role.
    var role: String?

    /// Current business context (fundraising, hiring, launching, etc.).
    var liveContext: String?

    /// Promised next action, introduction, reminder, or follow-up.
    var followUp: String?

    /// Memorable personal detail (family, interests, location, etc.).
    var personalDetail: String?

    /// Relationship tags (Founder, Investor, AI, Healthtech, Follow-up, etc.).
    var tags: [String] = []
}

/// Extracts structured person data from voice transcripts.
///
/// On-device AI extraction using Foundation Models (iOS 26+) with fallback to regex-based parsing.
/// Handles name, company, role, context, follow-ups, personal details, and tags.
///
/// - Note: Runs on-device using Apple Intelligence. No data is sent to cloud.
@Observable
class AIExtractionManager {
    /// Whether extraction is currently in progress.
    var isExtracting = false

    /// Result of the last extraction, if any.
    var extractedData: ExtractedPersonData?

    /// Error message if extraction failed and no fallback was used.
    var error: String?

    /// Extracts structured person data from a voice transcript.
    ///
    /// Tries Foundation Models first; falls back to regex parsing if unavailable.
    /// Extraction includes name, company, role, business context, follow-ups, personal details, and tags.
    ///
    /// - Parameters:
    ///   - text: The voice transcript to extract from.
    func extractFromTranscription(_ text: String) async {
        isExtracting = true
        defer { isExtracting = false }

        if let data = await extractWithFoundationModels(text) {
            self.extractedData = data
            return
        }

        self.extractedData = Self.fallbackExtract(text)
    }

    /// Fallback regex-based extraction when Foundation Models are unavailable.
    ///
    /// Uses heuristic pattern matching to extract name, company, role, and context.
    /// Always returns a result; fields are nil or empty if not found.
    ///
    /// - Parameters:
    ///   - text: The transcript to parse.
    ///
    /// - Returns: Extracted data with best-effort results.
    static func fallbackExtract(_ text: String) -> ExtractedPersonData {
        let cleanedText = cleanFreeformText(text)
        let words = words(in: cleanedText)
        let lowerWords = words.map { $0.lowercased() }

        var data = ExtractedPersonData()
        data.name = extractName(from: words, lowerWords: lowerWords)
        data.company = extractCompany(from: words, lowerWords: lowerWords)
        data.role = extractRole(from: words, lowerWords: lowerWords)
        data.liveContext = extractLiveContext(from: cleanedText)
        data.followUp = extractFollowUp(from: cleanedText)
        data.personalDetail = extractPersonalDetail(from: cleanedText)
        data.tags = extractTags(from: cleanedText, role: data.role)

        return data.normalized()
    }

    private func extractWithFoundationModels(_ text: String) async -> ExtractedPersonData? {
#if canImport(FoundationModels)
        guard case .available = SystemLanguageModel.default.availability else {
            return nil
        }

        do {
            let session = LanguageModelSession(instructions: Self.foundationModelInstructions)
            let response = try await session.respond(
                to: """
                Transcript:
                \(text)
                """,
                generating: PersonExtractionSchema.self
            )
            return response.content.extractedPersonData.normalized()
        } catch {
            self.error = "Apple Intelligence extraction was unavailable, so LinkMe used local parsing."
            return nil
        }
#else
        return nil
#endif
    }

    private static let foundationModelInstructions = """
    You extract relationship-memory fields from short speech transcripts for LinkMe.
    Return only information supported by the transcript.
    Do not include meeting verbs such as "met", "meet", "meeting", "spoke", or "talked" in a person's name.
    Clean speech punctuation from names. For example, "Hind Louis." is the name "Hind Louis".
    Prefer a full first and last name when present. If only one name is present, return that one name.
    For unknown fields, return an empty string or an empty tags array.
    Tags should be concise relationship labels like Founder, Investor, Exec, Healthtech, AI, Seed, Follow-up.
    Follow-up should capture promised next actions, future introductions, sends, reminders, or open loops. For "looking forward to introduce me to their CMO", create a follow-up about an intro to the CMO.
    Personal detail should be the smallest useful human detail fragment, such as "3 kids", not the full transcript.
    Live context should summarize timely business context only, such as fundraising, hiring, launching, or a current project. A company name alone is not live context. Do not put follow-up actions or personal details in live context. If there is no real live context, return an empty string.
    """
}

private extension ExtractedPersonData {
    func normalized() -> ExtractedPersonData {
        ExtractedPersonData(
            name: Self.cleanOptional(name),
            company: Self.cleanOptional(company),
            role: Self.cleanOptional(role),
            liveContext: Self.cleanOptional(liveContext),
            followUp: Self.cleanOptional(followUp),
            personalDetail: Self.cleanOptional(personalDetail),
            tags: tags
                .map { Self.cleanTag($0) }
                .filter { !$0.isEmpty }
                .uniqued()
        )
    }

    private static func cleanOptional(_ value: String?) -> String? {
        let cleaned = value.map(cleanField) ?? ""
        return cleaned.isEmpty ? nil : cleaned
    }

    private static func cleanField(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"'.,;:!?"))
    }

    private static func cleanTag(_ value: String) -> String {
        cleanField(value)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

private extension AIExtractionManager {
    static func cleanFreeformText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func words(in text: String) -> [String] {
        text
            .split(separator: " ")
            .map { cleanToken(String($0)) }
            .filter { !$0.isEmpty }
    }

    static func cleanToken(_ token: String) -> String {
        token.trimmingCharacters(in: CharacterSet(charactersIn: "\"'.,;:!?()[]{}"))
    }

    static func extractName(from words: [String], lowerWords: [String]) -> String? {
        guard !words.isEmpty else { return nil }

        let stopWords: Set<String> = [
            "at", "from", "with", "who", "that", "and", "about", "around",
            "for", "to", "on", "in", "during", "because", "needs", "need",
            "is", "was", "works", "building", "founder", "ceo", "cto", "cfo",
            "coo", "partner", "investor", "director", "manager", "vp", "head"
        ]
        let leadingWords: Set<String> = [
            "i", "we", "just", "today", "tonight", "yesterday", "finally",
            "met", "meet", "meeting", "spoke", "saw", "talked", "connected",
            "introduced", "caught", "up", "with"
        ]

        var startIndex = 0
        while startIndex < lowerWords.count, leadingWords.contains(lowerWords[startIndex]) {
            startIndex += 1
        }

        var nameTokens: [String] = []
        for index in startIndex..<words.count {
            let lower = lowerWords[index]
            if stopWords.contains(lower) { break }
            if isLikelyNameToken(words[index]) || isLikelyLowercaseNameToken(lower) || isNameParticle(lower) {
                nameTokens.append(normalizedNameToken(words[index]))
                if nameTokens.count == 4 { break }
            } else if !nameTokens.isEmpty {
                break
            }
        }

        if nameTokens.isEmpty, words.count == 2, words.allSatisfy({ isLikelyNameToken($0) || isLikelyLowercaseNameToken($0.lowercased()) }) {
            nameTokens = words.map(normalizedNameToken)
        }

        return nameTokens.isEmpty ? nil : nameTokens.joined(separator: " ")
    }

    static func extractCompany(from words: [String], lowerWords: [String]) -> String? {
        let markers = ["at", "from", "with"]
        guard let markerIndex = lowerWords.firstIndex(where: { markers.contains($0) }),
              markerIndex < words.count - 1 else {
            return nil
        }

        let stopWords: Set<String> = [
            "as", "who", "and", "but", "because", "needs", "need", "talked",
            "spoke", "met", "about", "on", "for", "follow", "send", "intro",
            "connect", "looking", "look", "forward"
        ]
        var companyTokens: [String] = []
        for index in (markerIndex + 1)..<words.count {
            let lower = lowerWords[index]
            if lower.rangeOfCharacter(from: .decimalDigits) != nil { break }
            if stopWords.contains(lower) { break }
            if isLikelyCompanyToken(words[index]) || isLikelyLowercaseCompanyToken(lower) || lower == "and" {
                companyTokens.append(normalizedCompanyToken(words[index]))
                if companyTokens.count == 5 { break }
            } else if !companyTokens.isEmpty {
                break
            }
        }

        return companyTokens.isEmpty ? nil : companyTokens.joined(separator: " ")
    }

    static func extractRole(from words: [String], lowerWords: [String]) -> String? {
        let roleTerms: Set<String> = [
            "founder", "cofounder", "co-founder", "ceo", "cto", "cfo", "coo",
            "partner", "investor", "angel", "director", "manager", "vp",
            "president", "lead", "head", "operator", "builder"
        ]

        guard let roleIndex = lowerWords.firstIndex(where: { roleTerms.contains($0) }) else {
            return nil
        }

        var roleTokens = [normalizedRoleToken(words[roleIndex])]
        if roleIndex > 0, ["co", "cofounder", "co-founder"].contains(lowerWords[roleIndex - 1]) {
            roleTokens.insert(normalizedRoleToken(words[roleIndex - 1]), at: 0)
        }
        if roleIndex < words.count - 2, lowerWords[roleIndex + 1] == "and", roleTerms.contains(lowerWords[roleIndex + 2]) {
            roleTokens.append(words[roleIndex + 1])
            roleTokens.append(normalizedRoleToken(words[roleIndex + 2]))
        }

        return roleTokens.joined(separator: " ")
    }

    static func extractLiveContext(from text: String) -> String? {
        let lower = text.lowercased()
        let contextMarkers = [
            "building", "launching", "raising", "fundraising", "hiring",
            "closing", "working on", "needs", "interested in",
            "talked about", "discussed"
        ]

        guard let marker = contextMarkers.first(where: { lower.contains($0) }),
              let range = lower.range(of: marker) else {
            return nil
        }

        return String(text[range.lowerBound...])
    }

    static func extractFollowUp(from text: String) -> String? {
        let lower = text.lowercased()
        if let introTarget = extractIntroTarget(from: text) {
            return "Intro to \(introTarget)"
        }

        let followUpMarkers = [
            "follow up", "send", "intro", "introduce", "connect", "email",
            "remind", "share", "promised", "next week", "tomorrow"
        ]

        guard followUpMarkers.contains(where: { lower.contains($0) }) else {
            return nil
        }

        return focusedFragment(from: text, startingAtAny: followUpMarkers) ?? text
    }

    static func extractPersonalDetail(from text: String) -> String? {
        let lower = text.lowercased()
        if let childrenDetail = firstRegexMatch(
            in: text,
            pattern: #"(?i)\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten)\s+(kids?|children|sons?|daughters?)\b"#
        ) {
            return childrenDetail.lowercased()
        }

        let personalMarkers = [
            "lives in", "based in", "likes", "loves", "family", "kids",
            "daughter", "son", "wife", "husband", "partner", "hobby",
            "enjoys", "from"
        ]

        guard personalMarkers.contains(where: { lower.contains($0) }) else {
            return nil
        }

        return focusedFragment(from: text, startingAtAny: personalMarkers) ?? text
    }

    static func extractTags(from text: String, role: String?) -> [String] {
        let lower = text.lowercased()
        let roleLower = role?.lowercased() ?? ""
        var tags: [String] = []

        if roleLower.contains("founder") || lower.contains("founder") { tags.append("Founder") }
        if roleLower.contains("investor") || roleLower.contains("partner") || lower.contains("investor") { tags.append("Investor") }
        if roleLower.contains("ceo") || roleLower.contains("vp") || lower.contains("exec") { tags.append("Exec") }
        if lower.contains("health") || lower.contains("medtech") { tags.append("Healthtech") }
        if lower.contains("ai") || lower.contains("machine learning") { tags.append("AI") }
        if lower.contains("seed") { tags.append("Seed") }
        if lower.contains("series a") { tags.append("Series A") }
        if lower.contains("series b") { tags.append("Series B") }
        if extractFollowUp(from: text) != nil { tags.append("Follow-up") }

        return tags
    }

    static func isLikelyNameToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isUppercase && token.dropFirst().allSatisfy { $0.isLetter || $0 == "-" || $0 == "'" }
    }

    static func isLikelyLowercaseNameToken(_ token: String) -> Bool {
        guard token.count > 1 else { return false }
        let blocked: Set<String> = [
            "met", "meet", "at", "from", "with", "who", "the", "their",
            "looking", "forward", "introduce", "intro", "kids", "children"
        ]
        return !blocked.contains(token) && token.allSatisfy { $0.isLetter || $0 == "-" || $0 == "'" }
    }

    static func normalizedNameToken(_ token: String) -> String {
        guard token == token.lowercased() else { return token }
        return token.prefix(1).uppercased() + token.dropFirst()
    }

    static func isNameParticle(_ token: String) -> Bool {
        ["da", "de", "del", "der", "di", "la", "le", "van", "von"].contains(token)
    }

    static func isLikelyCompanyToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        let corporateSuffixes = ["inc", "llc", "labs", "ventures", "capital", "studio", "systems", "ai"]
        return first.isUppercase || corporateSuffixes.contains(token.lowercased())
    }

    static func isLikelyLowercaseCompanyToken(_ token: String) -> Bool {
        guard token.count > 1 else { return false }
        let blocked: Set<String> = [
            "met", "meet", "vp", "ceo", "cto", "cfo", "coo", "partner",
            "founder", "kids", "children", "looking", "forward", "introduce"
        ]
        return !blocked.contains(token) && token.allSatisfy { $0.isLetter || $0 == "-" || $0 == "'" }
    }

    static func normalizedCompanyToken(_ token: String) -> String {
        guard token == token.lowercased() else { return token }
        return token.prefix(1).uppercased() + token.dropFirst()
    }

    static func normalizedRoleToken(_ token: String) -> String {
        switch token.lowercased() {
        case "ceo", "cto", "cfo", "coo", "vp":
            return token.uppercased()
        default:
            return token
        }
    }

    static func extractIntroTarget(from text: String) -> String? {
        let patterns = [
            #"(?i)\bintro(?:duce)?(?:\s+me)?\s+to\s+(?:his|her|their|the)?\s*([A-Za-z][A-Za-z &-]{1,40})"#,
            #"(?i)\bconnect(?:\s+me)?\s+(?:with|to)\s+(?:his|her|their|the)?\s*([A-Za-z][A-Za-z &-]{1,40})"#
        ]

        for pattern in patterns {
            if let target = firstRegexCapture(in: text, pattern: pattern, captureIndex: 1) {
                return target
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'.,;:!?"))
                    .uppercasedIfShortAcronym()
            }
        }

        return nil
    }

    static func focusedFragment(from text: String, startingAtAny markers: [String]) -> String? {
        let lower = text.lowercased()
        guard let range = markers.compactMap({ lower.range(of: $0) }).min(by: { $0.lowerBound < $1.lowerBound }) else {
            return nil
        }

        return String(text[range.lowerBound...])
    }

    static func firstRegexMatch(in text: String, pattern: String) -> String? {
        firstRegexCapture(in: text, pattern: pattern, captureIndex: 0)
    }

    static func firstRegexCapture(in text: String, pattern: String, captureIndex: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              captureIndex < match.numberOfRanges,
              let captureRange = Range(match.range(at: captureIndex), in: text) else {
            return nil
        }

        return String(text[captureRange])
    }
}

private extension String {
    func uppercasedIfShortAcronym() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 4 {
            return trimmed.uppercased()
        }
        return trimmed
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#if canImport(FoundationModels)
@Generable(description: "Structured person information extracted from a short relationship-capture transcript")
private struct PersonExtractionSchema {
    @Guide(description: "Full name of the person, excluding verbs and punctuation. Empty if no name is present.")
    var name: String

    @Guide(description: "Company, fund, school, or organization. Empty if unknown.")
    var company: String

    @Guide(description: "Role or title, such as Founder, CEO, Partner, VP Product. Empty if unknown.")
    var role: String

    @Guide(description: "Concise summary of the timely context or reason this person matters now. Empty if unknown.")
    var liveContext: String

    @Guide(description: "Promised next action, open loop, reminder, intro, or message to send. Empty if unknown.")
    var followUp: String

    @Guide(description: "Personal memorable detail such as interests, family, location, or preferences. Empty if unknown.")
    var personalDetail: String

    @Guide(description: "Three to six concise tags for relationship type, industry, stage, or follow-up status.")
    var tags: [String]

    var extractedPersonData: ExtractedPersonData {
        ExtractedPersonData(
            name: name,
            company: company,
            role: role,
            liveContext: liveContext,
            followUp: followUp,
            personalDetail: personalDetail,
            tags: tags
        )
    }
}
#endif

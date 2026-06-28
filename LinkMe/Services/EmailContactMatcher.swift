import Foundation

/// Matches email-extracted contacts to existing Person records.
///
/// Priority: exact email match → fuzzy name+company → create new.
final class EmailContactMatcher {

    /// Find existing person or return nil (caller creates new).
    ///
    /// - Parameters:
    ///   - name: Full name to search.
    ///   - company: Company name hint.
    ///   - email: Email address for exact match.
    ///
    /// - Returns: Matched PersonModel, or nil if no match found.
    @MainActor
    static func findPerson(name: String, company: String? = nil, email: String? = nil) -> PersonModel? {
        let db = DatabaseManager.shared

        // 1. Email exact match
        if let email, !email.isEmpty,
           let person = db.fetchPerson(byEmail: email) {
            return person
        }

        // 2. Name + company fuzzy
        if let company, !company.isEmpty {
            let candidates = db.fetchPeople(byCompanyApprox: company)
            if let match = candidates.first(where: { editDistance($0.name, name) <= 2 }) {
                return match
            }
        }

        // 3. Name-only fuzzy (broader search)
        let allPeople = db.fetchPeople()
        return allPeople.first(where: { editDistance($0.name, name) <= 1 })
    }

    /// Levenshtein edit distance between two strings.
    static func editDistance(_ a: String, _ b: String) -> Int {
        let a = a.lowercased(), b = b.lowercased()
        if a == b { return 0 }
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var prev = Array(0...b.count)
        for (i, ca) in a.enumerated() {
            var curr = [i + 1] + Array(repeating: 0, count: b.count)
            for (j, cb) in b.enumerated() {
                curr[j + 1] = ca == cb ? prev[j] : 1 + min(prev[j], prev[j + 1], curr[j])
            }
            prev = curr
        }
        return prev[b.count]
    }
}

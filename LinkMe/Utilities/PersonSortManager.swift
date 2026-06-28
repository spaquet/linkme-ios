import Foundation

/// Sort order options for people list.
enum PersonSortOption: String, CaseIterable {
    /// Most recently captured.
    case capturedRecent = "Most recent"
    /// Least recently captured (oldest first).
    case capturedOldest = "Least recent"
    /// Alphabetical by first name (A → Z).
    case nameAZ = "A → Z"
    /// Reverse alphabetical by first name (Z → A).
    case nameZA = "Z → A"
    /// Most recent last contact.
    case lastContactRecent = "Last contact"

    /// String identifier for UI.
    var id: String { self.rawValue }
}

/// Utilities for sorting people lists.
struct PersonSortManager {
    /// Sort a list of people by the given option.
    ///
    /// - Parameters:
    ///   - people: The people to sort.
    ///   - option: The sort criteria.
    ///
    /// - Returns: Sorted array of people.
    static func sort(_ people: [PersonModel], by option: PersonSortOption) -> [PersonModel] {
        switch option {
        case .capturedRecent:
            return people.sorted { $0.capturedAt > $1.capturedAt }
        case .capturedOldest:
            return people.sorted { $0.capturedAt < $1.capturedAt }
        case .nameAZ:
            return people.sorted { firstName($0) < firstName($1) }
        case .nameZA:
            return people.sorted { firstName($0) > firstName($1) }
        case .lastContactRecent:
            return people.sorted { person1, person2 in
                let date1 = person1.lastContact ?? .distantPast
                let date2 = person2.lastContact ?? .distantPast
                return date1 > date2
            }
        }
    }

    private static func firstName(_ person: PersonModel) -> String {
        person.name.split(separator: " ").first.map(String.init) ?? person.name
    }
}

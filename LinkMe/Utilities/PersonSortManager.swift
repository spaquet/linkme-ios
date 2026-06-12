import Foundation

enum PersonSortOption: String, CaseIterable {
    case capturedRecent = "Most recent"
    case capturedOldest = "Least recent"
    case nameAZ = "A → Z"
    case nameZA = "Z → A"
    case lastContactRecent = "Last contact"

    var id: String { self.rawValue }
}

struct PersonSortManager {
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

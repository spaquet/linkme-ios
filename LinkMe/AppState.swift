import Foundation

/// Storage wrapper for UserModel that excludes cards.
///
/// Encodes/decodes to UserDefaults. Cards are never stored here; always read from DatabaseManager.
struct UserModelForStorage: Codable {
    /// User's unique identifier.
    let id: String

    /// First name.
    var firstName: String

    /// Optional last name.
    var lastName: String?

    /// Creates storage wrapper from a UserModel.
    ///
    /// - Parameters:
    ///   - user: The user model to wrap (cards are discarded).
    init(from user: UserModel) {
        self.id = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
    }

    /// Convert storage wrapper back to UserModel.
    ///
    /// - Returns: A UserModel with empty cards array (load cards from DatabaseManager).
    func toUserModel() -> UserModel {
        UserModel(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            cards: []
        )
    }
}

/// Application-wide observable state.
///
/// Holds lightweight user identity and onboarding status. Persists to UserDefaults.
/// Rich profile data (cards) is stored exclusively in SQLite via ``DatabaseManager``.
@Observable
class AppState {
    /// Whether user has completed onboarding.
    var hasCompletedOnboarding: Bool = false {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    /// Lightweight user identity (id, firstName, lastName).
    ///
    /// The `cards` array is populated only from ``DatabaseManager``;
    /// it is never persisted to UserDefaults. Read cards from the database.
    var currentUser: UserModel? {
        didSet {
            if let user = currentUser {
                if let encoded = try? JSONEncoder().encode(UserModelForStorage(from: user)) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        }
    }

    /// Initialize app state from UserDefaults.
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let stored = try? JSONDecoder().decode(UserModelForStorage.self, from: data) {
            self.currentUser = stored.toUserModel()
        }
    }

    /// Clear all app data (UserDefaults and database).
    ///
    /// Used for logout or debugging. Resets to fresh onboarding state.
    func reset() {
        hasCompletedOnboarding = false
        currentUser = nil

        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()

        DatabaseManager.shared.clearAllData()
    }
}

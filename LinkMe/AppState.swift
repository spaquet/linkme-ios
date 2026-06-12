import Foundation

struct UserModelForStorage: Codable {
    let id: String
    var firstName: String
    var lastName: String?

    init(from user: UserModel) {
        self.id = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
    }

    func toUserModel() -> UserModel {
        UserModel(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            cards: []
        )
    }
}

@Observable
class AppState {
    var hasCompletedOnboarding: Bool = false {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

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

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let stored = try? JSONDecoder().decode(UserModelForStorage.self, from: data) {
            self.currentUser = stored.toUserModel()
        }
    }

    func reset() {
        hasCompletedOnboarding = false
        currentUser = nil
    }
}

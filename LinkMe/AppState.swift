import Foundation

@Observable
class AppState {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var currentUser: UserModel? {
        didSet {
            if let user = currentUser {
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.currentUser = user
        }
    }
}

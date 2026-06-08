import Foundation

struct UserModel: Codable {
    let id: String
    var name: String
    var role: String
    var company: String
    var email: String
    var tagline: String?
    var createdAt: Date

    init(id: String = UUID().uuidString, name: String, role: String, company: String, email: String, tagline: String? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.company = company
        self.email = email
        self.tagline = tagline
        self.createdAt = Date()
    }
}

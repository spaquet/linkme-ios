import Foundation

struct CardModel: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String?
    var email: String
    var phone: String?
    var avatar: String?
    var role: String
    var company: String
    var bio: String?
    var tagline: String?
    var location: String?
    var timezone: String?
    var pronouns: String?
    var socialLinks: [SocialLink]
    var paymentLinks: [PaymentLink]
    var chatApps: [ChatApp]
    var isDefault: Bool
    var sharedPublicly: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var name: String {
        if let lastName = lastName {
            return "\(firstName) \(lastName)"
        }
        return firstName
    }

    init(
        id: String = UUID().uuidString,
        firstName: String,
        lastName: String? = nil,
        email: String,
        phone: String? = nil,
        avatar: String? = nil,
        role: String,
        company: String,
        bio: String? = nil,
        tagline: String? = nil,
        location: String? = nil,
        timezone: String? = nil,
        pronouns: String? = nil,
        socialLinks: [SocialLink] = [],
        paymentLinks: [PaymentLink] = [],
        chatApps: [ChatApp] = [],
        isDefault: Bool = false,
        sharedPublicly: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.avatar = avatar
        self.role = role
        self.company = company
        self.bio = bio
        self.tagline = tagline
        self.location = location
        self.timezone = timezone
        self.pronouns = pronouns
        self.socialLinks = socialLinks
        self.paymentLinks = paymentLinks
        self.chatApps = chatApps
        self.isDefault = isDefault
        self.sharedPublicly = sharedPublicly
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }
}

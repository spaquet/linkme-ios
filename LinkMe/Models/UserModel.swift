import Foundation

struct SocialLink: Codable, Identifiable {
    let id: String
    var type: SocialLinkType
    var value: String

    init(type: SocialLinkType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

enum SocialLinkType: String, Codable, CaseIterable {
    case website
    case blog
    case x
    case instagram
    case linkedin
    case tiktok
    case threads
    case bluesky
}

struct PaymentLink: Codable, Identifiable {
    let id: String
    var type: PaymentLinkType
    var value: String

    init(type: PaymentLinkType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

enum PaymentLinkType: String, Codable, CaseIterable {
    case stripe
    case venmo
    case paypal
    case square
    case cashapp
}

struct ChatApp: Codable, Identifiable {
    let id: String
    var type: ChatAppType
    var value: String

    init(type: ChatAppType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

enum ChatAppType: String, Codable, CaseIterable {
    case whatsapp
    case wechat
    case signal
    case telegram
    case imessage
}

struct UserModel: Codable {
    let id: String
    var firstName: String
    var lastName: String?
    var cards: [CardModel]

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
        cards: [CardModel] = []
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.cards = cards
    }

    var defaultCard: CardModel? {
        cards.first { $0.isDefault }
    }
}

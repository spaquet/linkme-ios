import Foundation

/// A social media link attached to a card.
///
/// Represents a user's presence on a social platform (website, blog, X, LinkedIn, etc.).
struct SocialLink: Codable, Identifiable {
    /// Unique identifier for this social link.
    let id: String

    /// The type of social platform.
    var type: SocialLinkType

    /// The URL or handle value.
    var value: String

    /// Creates a new social link.
    ///
    /// - Parameters:
    ///   - type: The social platform type.
    ///   - value: The URL or handle.
    init(type: SocialLinkType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

/// Supported social platforms for user profiles.
enum SocialLinkType: String, Codable, CaseIterable {
    /// Personal website.
    case website
    /// Blog or publication.
    case blog
    /// X (formerly Twitter).
    case x
    /// Instagram.
    case instagram
    /// LinkedIn.
    case linkedin
    /// TikTok.
    case tiktok
    /// Threads (Meta).
    case threads
    /// Bluesky.
    case bluesky
}

/// A payment service link attached to a card.
///
/// Allows recipients to send payment or support the user via a payment platform.
struct PaymentLink: Codable, Identifiable {
    /// Unique identifier for this payment link.
    let id: String

    /// The type of payment platform.
    var type: PaymentLinkType

    /// The account handle or link value.
    var value: String

    /// Creates a new payment link.
    ///
    /// - Parameters:
    ///   - type: The payment platform type.
    ///   - value: The account handle or link.
    init(type: PaymentLinkType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

/// Supported payment platforms for user profiles.
enum PaymentLinkType: String, Codable, CaseIterable {
    /// Stripe payment link.
    case stripe
    /// Venmo peer payment.
    case venmo
    /// PayPal.
    case paypal
    /// Square Cash.
    case square
    /// Cash App.
    case cashapp
}

/// A messaging app contact attached to a card.
///
/// Allows recipients to contact the user via a messaging platform.
struct ChatApp: Codable, Identifiable {
    /// Unique identifier for this chat app link.
    let id: String

    /// The type of messaging platform.
    var type: ChatAppType

    /// The account handle or phone number.
    var value: String

    /// Creates a new chat app link.
    ///
    /// - Parameters:
    ///   - type: The messaging platform type.
    ///   - value: The account handle or phone number.
    init(type: ChatAppType, value: String) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}

/// Supported messaging platforms for user profiles.
enum ChatAppType: String, Codable, CaseIterable {
    /// WhatsApp.
    case whatsapp
    /// WeChat.
    case wechat
    /// Signal.
    case signal
    /// Telegram.
    case telegram
    /// iMessage.
    case imessage
}

/// Lightweight user identity model.
///
/// Stores only essential user identity (id, firstName, lastName). Rich profile data
/// is stored in ``CardModel`` objects in SQLite. The `cards` array is populated only
/// from the database during CardListView seeding; it is never persisted to UserDefaults.
///
/// - Note: UserModel is used for identity and AppState serialization only.
///   Never add card data to this model. Always read cards from ``DatabaseManager``.
struct UserModel: Codable {
    /// Unique identifier for the user.
    let id: String

    /// User's first name.
    var firstName: String

    /// Optional last name.
    var lastName: String?

    /// Array of user's cards (populated from database, not persisted to UserDefaults).
    var cards: [CardModel]

    /// Computed full name (firstName + lastName).
    var name: String {
        if let lastName = lastName {
            return "\(firstName) \(lastName)"
        }
        return firstName
    }

    /// Creates a new user record.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided).
    ///   - firstName: User's first name.
    ///   - lastName: Optional last name.
    ///   - cards: Array of cards (for seeding from database only).
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

    /// The default card marked with `isDefault == true`, or nil if none.
    var defaultCard: CardModel? {
        cards.first { $0.isDefault }
    }
}

import Foundation

/// A personal identity card in the LinkMe system.
///
/// The user's public-facing profile, shared with contacts via web card link (share-back).
/// Cards are stored exclusively in SQLite; never in UserDefaults.
///
/// - Important: CardModel is the single source of truth for a user's profile data.
///   Always persist via ``DatabaseManager``. Never serialize to UserDefaults.
///   This ensures sync consistency and enables future cloud sync without UserDefaults pollution.
struct CardModel: Codable, Identifiable {
    /// Unique identifier for this card (UUID).
    let id: String

    /// Full display name.
    var name: String

    /// Optional nickname or alias.
    var nickname: String?

    /// First name component.
    var firstName: String

    /// Optional last name component.
    var lastName: String?

    /// Email address (required for share-back).
    var email: String

    /// Optional phone number.
    var phone: String?

    /// Optional avatar image (base64 or URL).
    var avatar: String?

    /// Job title or role.
    var role: String

    /// Company or organization name.
    var company: String

    /// Optional biographical or professional summary.
    var bio: String?

    /// Optional one-liner tagline ("What I do").
    var tagline: String?

    /// Optional location or city.
    var location: String?

    /// Optional timezone (e.g., "America/New_York").
    var timezone: String?

    /// Optional pronouns (e.g., "he/him", "she/her").
    var pronouns: String?

    /// Social media links (website, blog, X, LinkedIn, etc.).
    var socialLinks: [SocialLink]

    /// Payment links (Stripe, Venmo, PayPal, etc.).
    var paymentLinks: [PaymentLink]

    /// Chat app handles (WhatsApp, WeChat, Signal, etc.).
    var chatApps: [ChatApp]

    /// Whether this is the default card for the user.
    var isDefault: Bool

    /// Whether this card is shared publicly or requires authentication.
    var sharedPublicly: Bool

    /// Timestamp when the card was created.
    var createdAt: Date

    /// Timestamp of the last update to this card.
    var updatedAt: Date

    /// Soft-delete timestamp; nil if card is active.
    var deletedAt: Date?

    /// Computed full name (firstName + lastName).
    var fullName: String {
        if let lastName = lastName {
            return "\(firstName) \(lastName)"
        }
        return firstName
    }

    /// Creates a new card.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided).
    ///   - name: Full display name.
    ///   - nickname: Optional nickname or alias.
    ///   - firstName: First name component.
    ///   - lastName: Optional last name.
    ///   - email: Email address (required).
    ///   - phone: Optional phone number.
    ///   - avatar: Optional avatar image.
    ///   - role: Job title.
    ///   - company: Company or organization.
    ///   - bio: Optional biography.
    ///   - tagline: Optional one-liner.
    ///   - location: Optional location.
    ///   - timezone: Optional timezone.
    ///   - pronouns: Optional pronouns.
    ///   - socialLinks: Social media links.
    ///   - paymentLinks: Payment links.
    ///   - chatApps: Chat app handles.
    ///   - isDefault: Whether this is the default card.
    ///   - sharedPublicly: Whether the card is publicly shared.
    init(
        id: String = UUID().uuidString,
        name: String,
        nickname: String? = nil,
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
        self.name = name
        self.nickname = nickname
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

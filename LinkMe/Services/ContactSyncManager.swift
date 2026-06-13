import Combine
import Contacts
import Foundation

enum ContactSyncState: Equatable {
    case off
    case needsPermission
    case syncing
    case synced
    case denied
    case failed(String)

    var label: String {
        switch self {
        case .off: "Off"
        case .needsPermission: "Needs permission"
        case .syncing: "Syncing"
        case .synced: "Synced"
        case .denied: "Denied"
        case .failed: "Failed"
        }
    }
}

struct ContactSyncStats {
    var imported = 0
    var updated = 0
    var exported = 0
    var total = 0
    var stored = 0
    var lastSyncedAt: Date?
}

@MainActor
final class ContactSyncManager: ObservableObject {
    static let shared = ContactSyncManager()

    @Published private(set) var isEnabled: Bool
    @Published private(set) var state: ContactSyncState
    @Published private(set) var stats: ContactSyncStats

    private let store = CNContactStore()
    private let enabledKey = "contactSyncEnabled"

    private init() {
        let savedIsEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        isEnabled = savedIsEnabled
        stats = ContactSyncStats()
        state = savedIsEnabled ? .needsPermission : .off
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: enabledKey)

        guard enabled else {
            state = .off
            return
        }

        Task {
            await sync()
        }
    }

    func refreshIfEnabled() {
        guard isEnabled else {
            state = .off
            return
        }

        Task {
            await sync()
        }
    }

    func sync() async {
        guard isEnabled else {
            state = .off
            return
        }

        state = .syncing

        do {
            let authorized = try await requestAccessIfNeeded()
            guard authorized else {
                state = .denied
                return
            }

            let contacts = try await fetchContacts()
            var nextStats = ContactSyncStats(total: contacts.count, lastSyncedAt: Date())

            let batchSize = 200
            for batchStart in stride(from: 0, to: contacts.count, by: batchSize) {
                let batchEnd = min(batchStart + batchSize, contacts.count)
                let batch = Array(contacts[batchStart..<batchEnd])

                let (imported, updated) = await processBatch(batch, lastSyncedAt: nextStats.lastSyncedAt ?? Date())
                nextStats.imported += imported
                nextStats.updated += updated

                await MainActor.run {
                    self.stats = nextStats
                }
            }

            let validContactIdentifiers = Set(contacts.map(\.identifier))
            DatabaseManager.shared.deletePlaceholderContactPeople(excluding: validContactIdentifiers)
            nextStats.exported = await exportLinkedPeople(validContactIdentifiers: validContactIdentifiers)
            nextStats.stored = DatabaseManager.shared.fetchPeople().filter { $0.appleContactIdentifier != nil }.count
            stats = nextStats
            state = .synced
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private nonisolated func processBatch(_ contacts: [CNContact], lastSyncedAt: Date) async -> (imported: Int, updated: Int) {
        await Task.detached(priority: .background) {
            var imported = 0
            var updated = 0

            for contact in contacts {
                let existing = DatabaseManager.shared.fetchPerson(appleContactIdentifier: contact.identifier)
                var person = existing ?? PersonModel(
                    id: "apple-contact-\(contact.identifier)",
                    name: Self.displayName(for: contact),
                    company: contact.organizationName,
                    role: contact.jobTitle
                )

                if existing == nil {
                    imported += 1
                } else if person.appleContactSyncChecksum != Self.contactChecksum(contact) {
                    updated += 1
                }

                person.name = Self.displayName(for: contact)
                person.company = contact.organizationName
                person.role = contact.jobTitle
                person.appleContactIdentifier = contact.identifier
                person.appleContactLastSyncedAt = lastSyncedAt
                person.appleContactSyncChecksum = Self.contactChecksum(contact)
                person.appleContactSnapshotJson = Self.contactSnapshotJson(contact)
                person.tags = Self.mergedTags(person.tags, contact: contact)

                DatabaseManager.shared.upsertPerson(person)
            }

            return (imported, updated)
        }.value
    }

    private func requestAccessIfNeeded() async throws -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return try await store.requestAccess(for: .contacts)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func fetchContacts() async throws -> [CNContact] {
        try await Task.detached(priority: .background) {
            let store = CNContactStore()
            let keys = Self.contactFetchKeys()
            var contacts: [CNContact] = []
            let request = CNContactFetchRequest(keysToFetch: keys)
            request.sortOrder = .userDefault

            try store.enumerateContacts(with: request) { contact, _ in
                if Self.hasUsefulContactData(contact) {
                    contacts.append(contact)
                }
            }

            return contacts
        }.value
    }

    private func exportLinkedPeople(validContactIdentifiers: Set<String>) async -> Int {
        let people = DatabaseManager.shared.fetchPeople().filter { $0.appleContactIdentifier != nil }
        return await Task.detached(priority: .utility) {
            let store = CNContactStore()
            var exported = 0

            for person in people {
                guard let identifier = person.appleContactIdentifier,
                      validContactIdentifiers.contains(identifier) else {
                    continue
                }

                do {
                    let contact = try store.unifiedContact(
                        withIdentifier: identifier,
                        keysToFetch: [
                            CNContactGivenNameKey as CNKeyDescriptor,
                            CNContactFamilyNameKey as CNKeyDescriptor,
                            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                            CNContactOrganizationNameKey as CNKeyDescriptor,
                            CNContactJobTitleKey as CNKeyDescriptor
                        ]
                    ).mutableCopy() as! CNMutableContact

                    guard Self.personNeedsExport(person, to: contact) else {
                        continue
                    }

                    let nameParts = person.name.split(separator: " ", maxSplits: 1).map(String.init)
                    contact.givenName = nameParts.first ?? person.name
                    contact.familyName = nameParts.dropFirst().first ?? ""
                    contact.organizationName = person.company
                    contact.jobTitle = person.role

                    let request = CNSaveRequest()
                    request.update(contact)
                    try store.execute(request)
                    exported += 1
                } catch {
                    continue
                }
            }

            return exported
        }.value
    }

    private nonisolated static func contactFetchKeys() -> [CNKeyDescriptor] {
        [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactDepartmentNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactNicknameKey as CNKeyDescriptor,
            CNContactPhoneticGivenNameKey as CNKeyDescriptor,
            CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
            CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
            CNContactPreviousFamilyNameKey as CNKeyDescriptor,
            CNContactNameSuffixKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactUrlAddressesKey as CNKeyDescriptor,
            CNContactSocialProfilesKey as CNKeyDescriptor,
            CNContactInstantMessageAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactNonGregorianBirthdayKey as CNKeyDescriptor,
            CNContactDatesKey as CNKeyDescriptor,
            CNContactRelationsKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
    }

    private nonisolated static func displayName(for contact: CNContact) -> String {
        let formatter = CNContactFormatter()
        formatter.style = .fullName

        if let formatted = formatter.string(from: contact), !formatted.isEmpty {
            return formatted
        }

        let name = [contact.givenName, contact.familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if !name.isEmpty {
            return name
        }

        if !contact.organizationName.isEmpty {
            return contact.organizationName
        }

        if let email = contact.emailAddresses.first?.value, !String(email).isEmpty {
            return String(email)
        }

        if let phone = contact.phoneNumbers.first?.value.stringValue, !phone.isEmpty {
            return phone
        }

        return "Unnamed contact"
    }

    private nonisolated static func hasUsefulContactData(_ contact: CNContact) -> Bool {
        !contact.givenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !contact.familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !contact.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !contact.organizationName.isEmpty ||
            !contact.emailAddresses.isEmpty ||
            !contact.phoneNumbers.isEmpty
    }

    private nonisolated static func mergedTags(_ tags: [String], contact: CNContact) -> [String] {
        var merged = tags
        if !contact.organizationName.isEmpty, !merged.contains("Contact") {
            merged.append("Contact")
        }
        return merged
    }

    private nonisolated static func contactChecksum(_ contact: CNContact) -> String {
        [
            Self.displayName(for: contact),
            contact.organizationName,
            contact.jobTitle,
            contact.phoneNumbers.map { $0.value.stringValue }.joined(separator: "|"),
            contact.emailAddresses.map { String($0.value) }.joined(separator: "|")
        ].joined(separator: "::")
    }

    private nonisolated static func contactSnapshotJson(_ contact: CNContact) -> String? {
        var snapshot: [String: Any] = ["identifier": contact.identifier]

        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactNamePrefixKey, outputKey: "namePrefix", value: contact.namePrefix)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactGivenNameKey, outputKey: "givenName", value: contact.givenName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactMiddleNameKey, outputKey: "middleName", value: contact.middleName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactFamilyNameKey, outputKey: "familyName", value: contact.familyName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactPreviousFamilyNameKey, outputKey: "previousFamilyName", value: contact.previousFamilyName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactNameSuffixKey, outputKey: "nameSuffix", value: contact.nameSuffix)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactNicknameKey, outputKey: "nickname", value: contact.nickname)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactPhoneticGivenNameKey, outputKey: "phoneticGivenName", value: contact.phoneticGivenName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactPhoneticMiddleNameKey, outputKey: "phoneticMiddleName", value: contact.phoneticMiddleName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactPhoneticFamilyNameKey, outputKey: "phoneticFamilyName", value: contact.phoneticFamilyName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactOrganizationNameKey, outputKey: "organizationName", value: contact.organizationName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactDepartmentNameKey, outputKey: "departmentName", value: contact.departmentName)
        addIfAvailable(&snapshot, contact: contact, keyPath: CNContactJobTitleKey, outputKey: "jobTitle", value: contact.jobTitle)

        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            snapshot["phoneNumbers"] = contact.phoneNumbers.map { labeledValue($0.label, value: $0.value.stringValue) }
        }
        if contact.isKeyAvailable(CNContactEmailAddressesKey) {
            snapshot["emailAddresses"] = contact.emailAddresses.map { labeledValue($0.label, value: String($0.value)) }
        }
        if contact.isKeyAvailable(CNContactPostalAddressesKey) {
            snapshot["postalAddresses"] = contact.postalAddresses.map { labeledPostalAddress($0) }
        }
        if contact.isKeyAvailable(CNContactUrlAddressesKey) {
            snapshot["urlAddresses"] = contact.urlAddresses.map { labeledValue($0.label, value: String($0.value)) }
        }
        if contact.isKeyAvailable(CNContactSocialProfilesKey) {
            snapshot["socialProfiles"] = contact.socialProfiles.map { labeledSocialProfile($0) }
        }
        if contact.isKeyAvailable(CNContactInstantMessageAddressesKey) {
            snapshot["instantMessageAddresses"] = contact.instantMessageAddresses.map { labeledInstantMessageAddress($0) }
        }
        if contact.isKeyAvailable(CNContactBirthdayKey) {
            snapshot["birthday"] = dateComponents(contact.birthday) as Any
        }
        if contact.isKeyAvailable(CNContactNonGregorianBirthdayKey) {
            snapshot["nonGregorianBirthday"] = dateComponents(contact.nonGregorianBirthday) as Any
        }
        if contact.isKeyAvailable(CNContactDatesKey) {
            snapshot["dates"] = contact.dates.map { labeledDateComponents($0) }
        }
        if contact.isKeyAvailable(CNContactRelationsKey) {
            snapshot["relations"] = contact.contactRelations.map { labeledValue($0.label, value: $0.value.name) }
        }
        if contact.isKeyAvailable(CNContactImageDataAvailableKey) {
            snapshot["imageDataAvailable"] = contact.imageDataAvailable
        }
        if contact.isKeyAvailable(CNContactImageDataKey) {
            snapshot["imageDataBase64"] = contact.imageData?.base64EncodedString() as Any
        }
        if contact.isKeyAvailable(CNContactThumbnailImageDataKey) {
            snapshot["thumbnailImageDataBase64"] = contact.thumbnailImageData?.base64EncodedString() as Any
        }

        guard JSONSerialization.isValidJSONObject(snapshot),
              let data = try? JSONSerialization.data(withJSONObject: snapshot, options: [.sortedKeys]),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    private nonisolated static func addIfAvailable(_ snapshot: inout [String: Any], contact: CNContact, keyPath: String, outputKey: String, value: String) {
        if contact.isKeyAvailable(keyPath) {
            snapshot[outputKey] = value
        }
    }

    private nonisolated static func labeledValue(_ label: String?, value: String) -> [String: String] {
        [
            "label": label ?? "",
            "value": value
        ]
    }

    private nonisolated static func labeledPostalAddress(_ value: CNLabeledValue<CNPostalAddress>) -> [String: String] {
        [
            "label": value.label ?? "",
            "street": value.value.street,
            "subLocality": value.value.subLocality,
            "city": value.value.city,
            "subAdministrativeArea": value.value.subAdministrativeArea,
            "state": value.value.state,
            "postalCode": value.value.postalCode,
            "country": value.value.country,
            "isoCountryCode": value.value.isoCountryCode
        ]
    }

    private nonisolated static func labeledSocialProfile(_ value: CNLabeledValue<CNSocialProfile>) -> [String: String] {
        [
            "label": value.label ?? "",
            "urlString": value.value.urlString,
            "username": value.value.username,
            "userIdentifier": value.value.userIdentifier,
            "service": value.value.service
        ]
    }

    private nonisolated static func labeledInstantMessageAddress(_ value: CNLabeledValue<CNInstantMessageAddress>) -> [String: String] {
        [
            "label": value.label ?? "",
            "username": value.value.username,
            "service": value.value.service
        ]
    }

    private nonisolated static func labeledDateComponents(_ value: CNLabeledValue<NSDateComponents>) -> [String: Any] {
        [
            "label": value.label ?? "",
            "date": dateComponents(value.value as DateComponents) ?? [:]
        ]
    }

    private nonisolated static func dateComponents(_ value: DateComponents?) -> [String: Int]? {
        guard let value else { return nil }
        var result: [String: Int] = [:]
        if let era = value.era { result["era"] = era }
        if let year = value.year { result["year"] = year }
        if let month = value.month { result["month"] = month }
        if let day = value.day { result["day"] = day }
        if let hour = value.hour { result["hour"] = hour }
        if let minute = value.minute { result["minute"] = minute }
        if let second = value.second { result["second"] = second }
        if let nanosecond = value.nanosecond { result["nanosecond"] = nanosecond }
        if let weekday = value.weekday { result["weekday"] = weekday }
        if let weekdayOrdinal = value.weekdayOrdinal { result["weekdayOrdinal"] = weekdayOrdinal }
        if let quarter = value.quarter { result["quarter"] = quarter }
        if let weekOfMonth = value.weekOfMonth { result["weekOfMonth"] = weekOfMonth }
        if let weekOfYear = value.weekOfYear { result["weekOfYear"] = weekOfYear }
        if let yearForWeekOfYear = value.yearForWeekOfYear { result["yearForWeekOfYear"] = yearForWeekOfYear }
        return result
    }

    private nonisolated static func personNeedsExport(_ person: PersonModel, to contact: CNContact) -> Bool {
        displayName(for: contact) != person.name ||
            contact.organizationName != person.company ||
            contact.jobTitle != person.role
    }

    private nonisolated func personSyncChecksum(_ person: PersonModel) -> String {
        person.appleContactSyncChecksum ?? ""
    }
}

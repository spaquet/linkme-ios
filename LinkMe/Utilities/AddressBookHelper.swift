import Contacts
import AddressBook
import Foundation

/// Creation and modification timestamps for a contact.
struct ContactDates {
    /// Date the contact was created in the system address book.
    let createdDate: Date?

    /// Date the contact was last modified in the system address book.
    let modifiedDate: Date?
}

/// Bridge to AddressBook framework for accessing contact timestamps unavailable in Contacts.
///
/// CNContact omits creation/modification timestamps. This helper opens the legacy AddressBook
/// once per sync pass and performs lightweight per-name searches within that open reference.
///
/// - Important: Requires Contacts permission. Uses deprecated AddressBook C API.
class AddressBookHelper {
    static let shared = AddressBookHelper()

    /// Opens a session holding an AddressBook reference for batch date lookups.
    ///
    /// - Returns: An open ABSession, or nil if AddressBook access fails.
    nonisolated func openSession() -> ABSession? {
        var error: Unmanaged<CFError>?
        guard let ref = ABAddressBookCreateWithOptions(nil, &error) else {
            if let e = error?.takeRetainedValue() {
                print("[AddressBook] Failed to open: \(e)")
            }
            return nil
        }
        return ABSession(addressBook: ref.takeRetainedValue())
    }
}

/// Holds an open AddressBook reference for the duration of a sync pass.
///
/// Open once via AddressBookHelper.openSession(), call dates(for:) per contact, then close().
///
/// - Important: Call close() when done. Retaining beyond the sync pass leaks the CF reference.
final class ABSession: @unchecked Sendable {
    private var addressBook: ABAddressBook?

    init(addressBook: ABAddressBook) {
        self.addressBook = addressBook
    }

    /// Looks up creation and modification dates for a contact.
    ///
    /// Calls ABAddressBookCopyPeopleWithName for a single lightweight search within the open
    /// reference. Disambiguates by phone number when multiple records match the name.
    /// Falls back to organization name when given/family name are both empty.
    ///
    /// - Parameters:
    ///   - contact: A CNContact to look up.
    /// - Returns: ContactDates with available timestamps, or nil dates if no match found.
    func dates(for contact: CNContact) -> ContactDates {
        guard let ab = addressBook else {
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        let searchName: String
        if contact.givenName.isEmpty && contact.familyName.isEmpty {
            searchName = contact.organizationName
        } else {
            searchName = [contact.givenName, contact.familyName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        }

        guard !searchName.isEmpty,
              let matchesRef = ABAddressBookCopyPeopleWithName(ab, searchName as CFString) else {
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        let matches = matchesRef.takeRetainedValue() as [ABRecord]
        guard !matches.isEmpty else {
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        let targetPhone = contact.phoneNumbers.first?.value.stringValue ?? ""
        let record: ABRecord?

        if matches.count == 1 {
            record = matches[0]
        } else if !targetPhone.isEmpty {
            record = matches.first { isPhoneInRecord($0, phone: targetPhone) } ?? matches[0]
        } else {
            record = matches[0]
        }

        guard let rec = record else {
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        var createdDate: Date?
        var modifiedDate: Date?

        if let ref = ABRecordCopyValue(rec, kABPersonCreationDateProperty) {
            createdDate = ref.takeRetainedValue() as? Date
        }
        if let ref = ABRecordCopyValue(rec, kABPersonModificationDateProperty) {
            modifiedDate = ref.takeRetainedValue() as? Date
        }

        return ContactDates(createdDate: createdDate, modifiedDate: modifiedDate)
    }

    /// Releases the AddressBook CF reference.
    func close() {
        addressBook = nil
    }

    private func isPhoneInRecord(_ record: ABRecord, phone: String) -> Bool {
        guard let phoneRef = ABRecordCopyValue(record, kABPersonPhoneProperty) else { return false }
        let phoneValue = phoneRef.takeRetainedValue()
        guard let phoneMultiValue = phoneValue as? ABMultiValue else { return false }
        for i in 0..<ABMultiValueGetCount(phoneMultiValue) {
            if let recordPhone = ABMultiValueCopyValueAtIndex(phoneMultiValue, i) {
                let val = recordPhone.takeRetainedValue() as? String ?? ""
                if val == phone { return true }
            }
        }
        return false
    }
}

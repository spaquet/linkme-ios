import Contacts
import AddressBook
import Foundation

/// Creation and modification timestamps for a contact.
///
/// The modern Contacts framework (CNContact) does not expose contact creation or modification dates.
/// This struct holds those timestamps retrieved from the legacy AddressBook framework.
struct ContactDates {
    /// Date the contact was created in the system address book.
    let createdDate: Date?

    /// Date the contact was last modified in the system address book.
    let modifiedDate: Date?
}

/// Bridge to AddressBook framework for accessing contact metadata unavailable in Contacts.
///
/// The modern Contacts framework (CNContact) exposes name, email, phone, and other profile data,
/// but omits creation and modification timestamps. LinkMe uses these timestamps to detect
/// when a person was first added to the device (as a proxy for relationship start date).
///
/// This helper queries the legacy AddressBook C API to retrieve those dates by matching
/// contacts by name and phone number.
///
/// - Important: Requires Contacts permission (same as Contacts framework). Deprecated AddressBook
///   APIs are used because CNContact provides no timestamp access.
class AddressBookHelper {
    static let shared = AddressBookHelper()

    /// Fetches creation and modification dates for a contact.
    ///
    /// Searches the address book for a contact matching the given name and first phone number.
    /// - Parameters:
    ///   - contact: A CNContact from the modern Contacts framework.
    /// - Returns: ContactDates with createdDate and modifiedDate if found; nil dates if not found or on error.
    func contactDates(for contact: CNContact) -> ContactDates {
        var error: Unmanaged<CFError>?
        guard let addressBookRef = ABAddressBookCreateWithOptions(nil, &error) else {
            if let error = error?.takeRetainedValue() {
                print("[AddressBook] Failed to create address book: \(error)")
            }
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        let addressBook = addressBookRef.takeRetainedValue()
        guard let peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(addressBook) else {
            print("[AddressBook] No contacts found")
            return ContactDates(createdDate: nil, modifiedDate: nil)
        }

        let peopleArray = peopleArrayRef.takeRetainedValue() as [ABRecord]
        let targetPhone = contact.phoneNumbers.first?.value.stringValue ?? ""

        for record in peopleArray {
            if let firstNameRef = ABRecordCopyValue(record, kABPersonFirstNameProperty),
               let lastNameRef = ABRecordCopyValue(record, kABPersonLastNameProperty) {
                let firstName = (firstNameRef.takeRetainedValue() as? String) ?? ""
                let lastName = (lastNameRef.takeRetainedValue() as? String) ?? ""

                let nameMatches = firstName == contact.givenName && lastName == contact.familyName
                let phoneMatches = !targetPhone.isEmpty && isPhoneInRecord(record, phone: targetPhone)

                if nameMatches && phoneMatches {
                    var createdDate: Date?
                    var modifiedDate: Date?

                    if let createdRef = ABRecordCopyValue(record, kABPersonCreationDateProperty) {
                        let createdValue = createdRef.takeRetainedValue()
                        if let date = createdValue as? Date {
                            createdDate = date
                        }
                    }

                    if let modifiedRef = ABRecordCopyValue(record, kABPersonModificationDateProperty) {
                        let modifiedValue = modifiedRef.takeRetainedValue()
                        if let date = modifiedValue as? Date {
                            modifiedDate = date
                        }
                    }

                    if let created = createdDate, let modified = modifiedDate {
                        print("[AddressBook] ✅ Found dates for \(firstName) \(lastName) (\(targetPhone))")
                        print("[AddressBook]    Created: \(created.formatted(date: .abbreviated, time: .standard))")
                        print("[AddressBook]    Modified: \(modified.formatted(date: .abbreviated, time: .standard))")
                    }

                    return ContactDates(createdDate: createdDate, modifiedDate: modifiedDate)
                }
            }
        }

        print("[AddressBook] No dates found for \(contact.givenName) \(contact.familyName)")
        return ContactDates(createdDate: nil, modifiedDate: nil)
    }

    /// Fetches only the creation date for a contact.
    ///
    /// Convenience method for callers that only need the created date.
    /// - Parameters:
    ///   - contact: A CNContact from the modern Contacts framework.
    /// - Returns: The contact creation date if found; nil otherwise.
    func creationDate(for contact: CNContact) -> Date? {
        contactDates(for: contact).createdDate
    }

    /// Checks if a phone number exists in an AddressBook record.
    ///
    /// Helper to match contacts by phone during the address book search.
    /// - Parameters:
    ///   - record: An ABRecord from the AddressBook framework.
    ///   - phone: Phone number string to search for.
    /// - Returns: true if the phone number exists in the record.
    private func isPhoneInRecord(_ record: ABRecord, phone: String) -> Bool {
        if let phoneRef = ABRecordCopyValue(record, kABPersonPhoneProperty) {
            let phoneValue = phoneRef.takeRetainedValue()
            if let phoneMultiValue = phoneValue as? ABMultiValue {
                for i in 0..<ABMultiValueGetCount(phoneMultiValue) {
                    if let recordPhone = ABMultiValueCopyValueAtIndex(phoneMultiValue, i) {
                        let recordPhoneValue = recordPhone.takeRetainedValue() as? String ?? ""
                        if recordPhoneValue == phone {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}

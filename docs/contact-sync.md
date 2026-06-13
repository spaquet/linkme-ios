# Contact Sync Architecture

## Overview

LinkMe syncs contacts from the device's Contacts app using two strategies:

1. **Incremental sync** (notification-based, fast)
2. **Full sync** (on-demand, comprehensive)

This hybrid approach balances responsiveness with efficiency for users with 1000+ device contacts.

## Sync Strategies

### Incremental Sync (Notification Listener)

Triggered by `CNContactStoreDidChange` notification when any contact changes on the device.

**Flow:**
1. Notification fires
2. Debounced 2 seconds (batches rapid edits)
3. Fetch all device contacts
4. Filter to: tracked contacts + new ones (not yet in LinkMe DB)
5. Process only those (via `processBatch()`)
6. Checksum comparison detects actual changes; only changed contacts are updated

**Performance:** For 1000+ contacts, only changed/new ones are written to DB.

**What it handles:**
- ✅ New contacts added to device → imported to LinkMe
- ✅ Existing contacts edited → updated in LinkMe
- ❌ Deleted contacts → NOT detected (see Full Sync)

### Full Sync

Comprehensive sync that fetches all device contacts and reconciles the database.

**Triggered by:**
1. First time user grants contact access → `setEnabled(true)` → `sync()`
2. Manual "Refresh" in PrivacyView → `forceResync()` → `sync()`

**Flow:**
1. Fetch all device contacts (paginated by 200)
2. Process each batch via `processBatch()` (import/update)
3. Compare against DB to find deleted contacts
4. Remove contacts from DB that no longer exist on device (via `deletePlaceholderContactPeople()`)
5. Export updated LinkMe cards back to device Contacts

**What it handles:**
- ✅ New contacts
- ✅ Updated contacts
- ✅ **Deleted contacts** (removed from LinkMe DB)
- ✅ Bi-directional sync (LinkMe → device)

## Scenarios & Behavior

| Scenario | Trigger | Sync Type | Result |
|----------|---------|-----------|--------|
| Contact edited | Device change notification | Incremental | Updated in LinkMe (2s debounce) |
| New contact added | Device change notification | Incremental | Imported to LinkMe (2s debounce) |
| Contact deleted | Device change notification | Incremental | **Stays in LinkMe** until full sync |
| App launch | User opens LinkMe | None | No sync (listener continues) |
| Manual refresh | User taps "Refresh" in Privacy | Full sync | All contact ops (add/update/delete) |
| First access | User grants Contacts permission | Full sync | Initial import |

## Technical Details

### Data Structures

**Tracked contacts:** PersonModel records with `appleContactIdentifier` (contact's device ID).

**Sync state:**
- `state: ContactSyncState` — off/needsPermission/syncing/synced/denied/failed
- `stats: ContactSyncStats` — imported/updated/exported/total counts
- `isEnabled: Bool` — user opt-in via PrivacyView toggle

### Checksum Optimization

During incremental sync, `processBatch()` compares contact checksums:

```swift
if person.appleContactSyncChecksum != Self.contactChecksum(contact) {
    updated += 1
    // update DB
}
```

This means fetching all contacts (expensive) is followed by selective DB writes (cheap).

### Debouncing

When user edits multiple contacts rapidly (e.g., bulk edit), notifications are debounced 2 seconds to avoid redundant syncs.

```swift
debounceTask?.cancel()
debounceTask = Task {
    try? await Task.sleep(nanoseconds: 2_000_000_000)  // 2s
    await syncTrackedContacts()
}
```

### Why Deletions Are Lazy

Detecting deleted contacts incrementally would require:
1. Fetching all device contacts to compare
2. Cross-checking every contact's presence

This is expensive for 1000+ contacts. Instead, deletions are detected only during full sync when the comparison is already happening.

**Trade-off:** Deleted contacts stay visible in LinkMe until user manually refreshes. Acceptable because:
- Deletions are rare vs. edits
- User can refresh anytime
- Notification listener keeps adds/edits fresh

## Future Improvements

1. **Periodically sync deletions** — Run lightweight deletion-check every N hours
2. **Change history API** — If iOS adds granular change history, use it instead of full fetch
3. **Selective full sync** — On notification, if any tracked contact changed, assume deletions might have happened too

## Code Structure

- **ContactSyncManager** — Main orchestrator
  - `setEnabled()` — Enable sync + start listener
  - `sync()` — Full sync
  - `forceResync()` — Manual full sync
  - `listenToContactChanges()` — Long-lived task listening for notifications
  - `syncTrackedContacts()` — Incremental sync from notification
  - `processBatch()` — Batch import/update logic
  - `fetchContacts()` — Get all device contacts

- **DatabaseManager** — Persistence
  - `upsertPerson()` — Add or update
  - `deletePerson()` — Remove by ID
  - `deletePlaceholderContactPeople()` — Remove orphaned records

## Testing

To test sync behavior:

1. **Incremental (notification):**
   - Enable sync in PrivacyView
   - Edit contact in Contacts app
   - Wait 2s, verify update in LinkMe

2. **New contact:**
   - Add contact in Contacts app
   - Wait 2s, verify appears in LinkMe

3. **Deletion:**
   - Delete contact in Contacts app
   - Verify stays in LinkMe (expected)
   - Tap "Refresh" in PrivacyView
   - Verify deleted from LinkMe

4. **Full sync:**
   - Disable sync, then re-enable
   - Should trigger full initial sync

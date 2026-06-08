# Database Observation Without GRDB

LinkMe currently uses raw `SQLite3` through `DatabaseManager`. We can add database observation without introducing GRDB.

## Recommended Approach

Use app-level notifications after successful database writes, then bridge those notifications into SwiftUI state.

This is the best first step because all current writes go through `DatabaseManager`, and the app does not need a full query-observation framework yet.

## Options

### 1. App-Level Notifications

Post a notification after each successful insert, update, or delete operation.

Example change type:

```swift
enum DatabaseChange {
    case people
    case notes(personId: String)
}

extension Notification.Name {
    static let databaseDidChange = Notification.Name("databaseDidChange")
}
```

Example write notification:

```swift
NotificationCenter.default.post(
    name: .databaseDidChange,
    object: DatabaseChange.people
)
```

A SwiftUI-facing store can observe this notification and reload affected data:

```swift
@Observable
final class PeopleStore {
    private let database: DatabaseManager
    private var observer: NSObjectProtocol?

    var people: [PersonModel] = []

    init(database: DatabaseManager = .shared) {
        self.database = database
        reload()

        observer = NotificationCenter.default.addObserver(
            forName: .databaseDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let change = notification.object as? DatabaseChange else { return }

            if case .people = change {
                self?.reload()
            }
        }
    }

    func reload() {
        people = database.fetchPeople()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
```

### 2. Swift Observation or Combine Bridge

Keep database access in repositories or stores, and expose observed values such as:

```swift
@Observable
final class PeopleStore {
    var people: [PersonModel] = []
}
```

Views then bind to the store instead of fetching directly from `DatabaseManager`.

This keeps SwiftUI updates predictable and gives the app one place to decide when data should be refreshed.

### 3. SQLite Update Hook

SQLite provides `sqlite3_update_hook`, which can report inserts, updates, and deletes for a database connection.

This is closer to low-level database observation, but it only tells us that a table row changed. It does not automatically update query results, so the app still needs to re-fetch affected values.

This can be useful later if writes might happen through multiple methods on the same SQLite connection.

### 4. Polling

Polling is possible, but it should be avoided unless database writes can happen outside the app or outside the observed SQLite connection.

Polling adds unnecessary work and can still miss intent-level details like which view model should refresh.

## Proposed Implementation Plan

1. Add `DatabaseChange` and `.databaseDidChange`.
2. Post changes from successful `DatabaseManager` write methods.
3. Introduce focused stores such as `PeopleStore` and `NotesStore`.
4. Bind SwiftUI views to those stores.
5. Add `sqlite3_update_hook` only if app-level notifications become insufficient.

## Tradeoffs

App-level notifications are simple, explicit, and fit the current codebase. The main limitation is that they only work reliably if all writes continue to go through `DatabaseManager`.

`sqlite3_update_hook` is more automatic, but it is lower-level and still requires Swift-side reload logic.

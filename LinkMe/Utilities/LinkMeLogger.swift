import os

extension Logger {
    private static let subsystem = "com.linkme.app"

    /// Database read/write operations and schema migrations.
    static let db = Logger(subsystem: subsystem, category: "database")

    /// Apple Contacts sync lifecycle, batches, and incremental updates.
    static let sync = Logger(subsystem: subsystem, category: "contact-sync")
}

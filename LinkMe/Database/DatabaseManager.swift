import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let dbPath: String

    private init() {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        if !fileManager.fileExists(atPath: appSupportURL.path) {
            try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        }

        dbPath = appSupportURL.appendingPathComponent("linkme.db").path
        openDatabase()
        initializeSchema()
        cleanupBrokenRecords()
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✓ Database opened at \(dbPath)")
        } else {
            print("✗ Error opening database")
        }
    }

    private func cleanupBrokenRecords() {
        let sql = "DELETE FROM people WHERE id IS NULL OR id = ''"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    private func initializeSchema() {
        let users = """
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            role TEXT,
            company TEXT,
            email TEXT,
            tagline TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        """

        let people = """
        CREATE TABLE IF NOT EXISTS people (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            company TEXT,
            role TEXT,
            tone TEXT DEFAULT 'teal',
            captured_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_contact DATETIME,
            is_favorite BOOLEAN DEFAULT 0,
            deleted_at DATETIME,
            context TEXT,
            personal TEXT,
            followup TEXT,
            tags TEXT,
            apple_contact_identifier TEXT,
            apple_contact_last_synced_at DATETIME,
            apple_contact_sync_checksum TEXT,
            apple_contact_snapshot_json TEXT
        );
        """

        let notes = """
        CREATE TABLE IF NOT EXISTS notes (
            id TEXT PRIMARY KEY,
            person_id TEXT NOT NULL,
            text TEXT NOT NULL,
            transcription TEXT,
            extracted_json TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            is_followup BOOLEAN DEFAULT 0,
            FOREIGN KEY (person_id) REFERENCES people(id)
        );
        """

        let contacts = """
        CREATE TABLE IF NOT EXISTS contacts (
            id TEXT PRIMARY KEY,
            person_id TEXT NOT NULL,
            type TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            location TEXT,
            attendees TEXT,
            FOREIGN KEY (person_id) REFERENCES people(id)
        );
        """

        let threads = """
        CREATE TABLE IF NOT EXISTS threads (
            id TEXT PRIMARY KEY,
            person_id TEXT NOT NULL,
            prompt TEXT NOT NULL,
            status TEXT DEFAULT 'open',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            due_at DATETIME,
            FOREIGN KEY (person_id) REFERENCES people(id)
        );
        """

        let shares = """
        CREATE TABLE IF NOT EXISTS shares (
            id TEXT PRIMARY KEY,
            person_id TEXT NOT NULL,
            token TEXT NOT NULL,
            sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            opened_at DATETIME,
            claimed_by_person_id TEXT,
            FOREIGN KEY (person_id) REFERENCES people(id)
        );
        """

        let relationships = """
        CREATE TABLE IF NOT EXISTS relationships (
            id TEXT PRIMARY KEY,
            person_a_id TEXT NOT NULL,
            person_b_id TEXT NOT NULL,
            shared_connection_date DATETIME,
            FOREIGN KEY (person_a_id) REFERENCES people(id),
            FOREIGN KEY (person_b_id) REFERENCES people(id)
        );
        """

        for createTableSQL in [users, people, notes, contacts, threads, shares, relationships] {
            executeSQL(createTableSQL)
        }

        migratePeopleSchema()
    }

    func executeSQL(_ sql: String) {
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &errorMessage) != SQLITE_OK {
            if let error = errorMessage {
                print("SQL Error: \(String(cString: error))")
                sqlite3_free(errorMessage)
            }
        }
    }

    func insertPerson(_ person: PersonModel) {
        let sql = """
        INSERT INTO people (id, name, company, role, tone, captured_at, is_favorite, context, personal, followup, tags, apple_contact_identifier, apple_contact_last_synced_at, apple_contact_sync_checksum, apple_contact_snapshot_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, person.id)
            bindText(statement, 2, person.name)
            bindText(statement, 3, person.company)
            bindText(statement, 4, person.role)
            bindText(statement, 5, person.tone)
            sqlite3_bind_int64(statement, 6, Int64(person.capturedAt.timeIntervalSince1970))
            sqlite3_bind_int(statement, 7, person.isFavorite ? 1 : 0)
            bindText(statement, 8, person.context)
            bindText(statement, 9, person.personal)
            bindText(statement, 10, person.followup)
            bindText(statement, 11, encodeTags(person.tags))
            bindText(statement, 12, person.appleContactIdentifier)
            bindDate(statement, 13, person.appleContactLastSyncedAt)
            bindText(statement, 14, person.appleContactSyncChecksum)
            bindText(statement, 15, person.appleContactSnapshotJson)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✓ Person inserted: \(person.name)")
            }
        }
        sqlite3_finalize(statement)
    }

    func upsertPerson(_ person: PersonModel) {
        let sql = """
        INSERT INTO people (id, name, company, role, tone, captured_at, last_contact, is_favorite, context, personal, followup, tags, apple_contact_identifier, apple_contact_last_synced_at, apple_contact_sync_checksum, apple_contact_snapshot_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            name = excluded.name,
            company = excluded.company,
            role = excluded.role,
            tone = excluded.tone,
            last_contact = excluded.last_contact,
            context = excluded.context,
            personal = excluded.personal,
            followup = excluded.followup,
            tags = excluded.tags,
            apple_contact_identifier = excluded.apple_contact_identifier,
            apple_contact_last_synced_at = excluded.apple_contact_last_synced_at,
            apple_contact_sync_checksum = excluded.apple_contact_sync_checksum,
            apple_contact_snapshot_json = excluded.apple_contact_snapshot_json
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, person.id)
            bindText(statement, 2, person.name)
            bindText(statement, 3, person.company)
            bindText(statement, 4, person.role)
            bindText(statement, 5, person.tone)
            sqlite3_bind_int64(statement, 6, Int64(person.capturedAt.timeIntervalSince1970))
            bindDate(statement, 7, person.lastContact)
            sqlite3_bind_int(statement, 8, person.isFavorite ? 1 : 0)
            bindText(statement, 9, person.context)
            bindText(statement, 10, person.personal)
            bindText(statement, 11, person.followup)
            bindText(statement, 12, encodeTags(person.tags))
            bindText(statement, 13, person.appleContactIdentifier)
            bindDate(statement, 14, person.appleContactLastSyncedAt)
            bindText(statement, 15, person.appleContactSyncChecksum)
            bindText(statement, 16, person.appleContactSnapshotJson)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchPerson(appleContactIdentifier: String) -> PersonModel? {
        fetchPeople().first { $0.appleContactIdentifier == appleContactIdentifier }
    }

    func deletePlaceholderContactPeople(excluding appleContactIdentifiers: Set<String>) {
        let placeholders = fetchPeople().filter { person in
            guard let identifier = person.appleContactIdentifier else { return false }
            return !appleContactIdentifiers.contains(identifier)
                && person.name == "Unnamed contact"
                && person.company.isEmpty
                && person.role.isEmpty
        }

        for person in placeholders {
            softDeletePerson(id: person.id)
        }
    }

    func deletePerson(id: String) {
        softDeletePerson(id: id)
    }

    private func softDeletePerson(id: String) {
        let sql = "UPDATE people SET deleted_at = ? WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, Int64(Date().timeIntervalSince1970))
            bindText(statement, 2, id)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchPeople() -> [PersonModel] {
        let sql = """
        SELECT id, name, company, role, tone, captured_at, last_contact, is_favorite, context, personal, followup, tags, apple_contact_identifier, apple_contact_last_synced_at, apple_contact_sync_checksum, apple_contact_snapshot_json
        FROM people
        WHERE deleted_at IS NULL
        ORDER BY captured_at DESC
        """
        var people: [PersonModel] = []

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let rawId = columnText(statement, 0)
                guard let id = rawId, !id.isEmpty else {
                    continue
                }
                let name = columnText(statement, 1) ?? "Unknown person"
                let company = columnText(statement, 2) ?? ""
                let role = columnText(statement, 3) ?? ""

                var person = PersonModel(id: id, name: name, company: company, role: role)
                person.tone = columnText(statement, 4) ?? "teal"
                person.capturedAt = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 5)))
                if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                    person.lastContact = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 6)))
                }
                person.isFavorite = sqlite3_column_int(statement, 7) == 1
                person.context = columnText(statement, 8) ?? ""
                person.personal = columnText(statement, 9) ?? ""
                person.followup = columnText(statement, 10) ?? ""
                person.tags = decodeTags(columnText(statement, 11))
                person.appleContactIdentifier = columnText(statement, 12)
                if sqlite3_column_type(statement, 13) != SQLITE_NULL {
                    person.appleContactLastSyncedAt = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 13)))
                }
                person.appleContactSyncChecksum = columnText(statement, 14)
                person.appleContactSnapshotJson = columnText(statement, 15)
                people.append(person)
            }
        }
        sqlite3_finalize(statement)
        return people
    }

    func insertNote(_ note: NoteModel) {
        let sql = """
        INSERT INTO notes (id, person_id, text, transcription, extracted_json, created_at, is_followup)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, note.id)
            bindText(statement, 2, note.personId)
            bindText(statement, 3, note.text)
            bindText(statement, 4, note.transcription)
            bindText(statement, 5, encodeExtractedJson(note.extractedJson))
            sqlite3_bind_int64(statement, 6, Int64(note.createdAt.timeIntervalSince1970))
            sqlite3_bind_int(statement, 7, note.isFollowUp ? 1 : 0)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✓ Note inserted")
            }
        }
        sqlite3_finalize(statement)
    }

    func fetchNotesForPerson(_ personId: String) -> [NoteModel] {
        let sql = "SELECT id, person_id, text, transcription, created_at FROM notes WHERE person_id = ? ORDER BY created_at DESC"
        var notes: [NoteModel] = []

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, personId, -1, nil)

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let pId = String(cString: sqlite3_column_text(statement, 1))
                let text = String(cString: sqlite3_column_text(statement, 2))
                let transcription = sqlite3_column_text(statement, 3).map { String(cString: $0) }

                let note = NoteModel(id: id, personId: pId, text: text, transcription: transcription)
                notes.append(note)
            }
        }
        sqlite3_finalize(statement)
        return notes
    }

    private func migratePeopleSchema() {
        addColumnIfMissing(table: "people", column: "context", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "personal", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "followup", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "tags", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "apple_contact_identifier", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "apple_contact_last_synced_at", definition: "DATETIME")
        addColumnIfMissing(table: "people", column: "apple_contact_sync_checksum", definition: "TEXT")
        addColumnIfMissing(table: "people", column: "apple_contact_snapshot_json", definition: "TEXT")
    }

    private func addColumnIfMissing(table: String, column: String, definition: String) {
        guard !columnExists(table: table, column: column) else { return }
        executeSQL("ALTER TABLE \(table) ADD COLUMN \(column) \(definition);")
    }

    private func columnExists(table: String, column: String) -> Bool {
        let sql = "PRAGMA table_info(\(table));"
        var statement: OpaquePointer?
        var exists = false

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if columnText(statement, 1) == column {
                    exists = true
                    break
                }
            }
        }

        sqlite3_finalize(statement)
        return exists
    }

    private func bindText(_ statement: OpaquePointer?, _ index: Int32, _ value: String?) {
        guard let value else {
            sqlite3_bind_null(statement, index)
            return
        }

        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        sqlite3_bind_text(statement, index, value, -1, transient)
    }

    private func bindDate(_ statement: OpaquePointer?, _ index: Int32, _ value: Date?) {
        guard let value else {
            sqlite3_bind_null(statement, index)
            return
        }

        sqlite3_bind_int64(statement, index, Int64(value.timeIntervalSince1970))
    }

    private func columnText(_ statement: OpaquePointer?, _ index: Int32) -> String? {
        guard let text = sqlite3_column_text(statement, index) else { return nil }
        return String(cString: text)
    }

    private func encodeTags(_ tags: [String]) -> String {
        guard let data = try? JSONEncoder().encode(tags),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }

        return json
    }

    private func decodeTags(_ json: String?) -> [String] {
        guard let json,
              let data = json.data(using: .utf8),
              let tags = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }

        return tags
    }

    private func encodeExtractedJson(_ extractedJson: [String: String]) -> String? {
        guard !extractedJson.isEmpty,
              let data = try? JSONEncoder().encode(extractedJson),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    deinit {
        sqlite3_close(db)
    }
}

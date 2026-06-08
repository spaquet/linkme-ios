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
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✓ Database opened at \(dbPath)")
        } else {
            print("✗ Error opening database")
        }
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
            deleted_at DATETIME
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
        INSERT INTO people (id, name, company, role, tone, captured_at, is_favorite)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, person.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, person.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, person.company, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, person.role, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, person.tone, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 6, Int64(person.capturedAt.timeIntervalSince1970))
            sqlite3_bind_int(statement, 7, person.isFavorite ? 1 : 0)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✓ Person inserted: \(person.name)")
            }
        }
        sqlite3_finalize(statement)
    }

    func fetchPeople() -> [PersonModel] {
        let sql = "SELECT id, name, company, role, tone, captured_at FROM people WHERE deleted_at IS NULL"
        var people: [PersonModel] = []

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let company = String(cString: sqlite3_column_text(statement, 2))
                let role = String(cString: sqlite3_column_text(statement, 3))

                var person = PersonModel(id: id, name: name, company: company, role: role)
                people.append(person)
            }
        }
        sqlite3_finalize(statement)
        return people
    }

    func insertNote(_ note: NoteModel) {
        let sql = """
        INSERT INTO notes (id, person_id, text, transcription, created_at, is_followup)
        VALUES (?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, note.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, note.personId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, note.text, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, note.transcription, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int64(statement, 5, Int64(note.createdAt.timeIntervalSince1970))
            sqlite3_bind_int(statement, 6, note.isFollowUp ? 1 : 0)

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
            sqlite3_bind_text(statement, 1, personId, -1, SQLITE_TRANSIENT)

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let pId = String(cString: sqlite3_column_text(statement, 1))
                let text = String(cString: sqlite3_column_text(statement, 2))
                let transcription = sqlite3_column_text(statement, 3).map { String(cString: $0) }

                var note = NoteModel(personId: pId, text: text, transcription: transcription)
                note.id = id
                notes.append(note)
            }
        }
        sqlite3_finalize(statement)
        return notes
    }

    deinit {
        sqlite3_close(db)
    }
}

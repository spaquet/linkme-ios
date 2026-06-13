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

        let personTags = """
        CREATE TABLE IF NOT EXISTS person_tags (
            person_id TEXT NOT NULL,
            tag TEXT NOT NULL,
            tag_normalized TEXT NOT NULL,
            PRIMARY KEY (person_id, tag_normalized),
            FOREIGN KEY (person_id) REFERENCES people(id)
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

        let personTagsIndex = """
        CREATE INDEX IF NOT EXISTS idx_person_tags_tag_normalized
        ON person_tags(tag_normalized, person_id);
        """

        let peopleCapturedIndex = """
        CREATE INDEX IF NOT EXISTS idx_people_deleted_captured
        ON people(deleted_at, captured_at);
        """

        let peopleNameIndex = """
        CREATE INDEX IF NOT EXISTS idx_people_deleted_name
        ON people(deleted_at, name);
        """

        let peopleLastContactIndex = """
        CREATE INDEX IF NOT EXISTS idx_people_deleted_last_contact
        ON people(deleted_at, last_contact);
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

        let cards = """
        CREATE TABLE IF NOT EXISTS cards (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            nickname TEXT,
            first_name TEXT NOT NULL,
            last_name TEXT,
            email TEXT NOT NULL,
            phone TEXT,
            avatar TEXT,
            role TEXT NOT NULL,
            company TEXT NOT NULL,
            bio TEXT,
            tagline TEXT,
            location TEXT,
            timezone TEXT,
            pronouns TEXT,
            social_links TEXT,
            payment_links TEXT,
            chat_apps TEXT,
            is_default BOOLEAN DEFAULT 0,
            shared_publicly BOOLEAN DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            deleted_at DATETIME
        );
        """

        let cardsIndexDefault = """
        CREATE INDEX IF NOT EXISTS idx_cards_is_default
        ON cards(is_default, deleted_at);
        """

        for createTableSQL in [users, people, personTags, personTagsIndex, peopleCapturedIndex, peopleNameIndex, peopleLastContactIndex, notes, contacts, threads, shares, relationships, cards, cardsIndexDefault] {
            executeSQL(createTableSQL)
        }

        migratePeopleSchema()
        migrateCardsSchema()
        backfillPersonTags()
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
                replaceTags(for: person.id, tags: person.tags)
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
            if sqlite3_step(statement) == SQLITE_DONE {
                replaceTags(for: person.id, tags: person.tags)
            }
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

    func fetchPeople(
        searchText: String,
        matchingTags tags: [String] = [],
        partialTagMatch: Bool = false,
        sortedBy sortOption: PersonSortOption = .capturedRecent,
        limit: Int,
        offset: Int
    ) -> [PersonModel] {
        let query = peopleQueryParts(searchText: searchText, matchingTags: tags, partialTagMatch: partialTagMatch)
        let sql = """
        SELECT DISTINCT p.id, p.name, p.company, p.role, p.tone, p.captured_at, p.last_contact, p.is_favorite, p.context, p.personal, p.followup, p.tags, p.apple_contact_identifier, p.apple_contact_last_synced_at, p.apple_contact_sync_checksum, p.apple_contact_snapshot_json
        FROM people p
        \(query.joinSQL)
        WHERE \(query.whereSQL)
        ORDER BY \(orderBySQL(for: sortOption))
        LIMIT \(max(1, limit)) OFFSET \(max(0, offset))
        """

        return fetchPeople(sql: sql, bindValues: query.bindValues)
    }

    func countPeople(searchText: String, matchingTags tags: [String] = [], partialTagMatch: Bool = false) -> Int {
        let query = peopleQueryParts(searchText: searchText, matchingTags: tags, partialTagMatch: partialTagMatch)
        let sql = """
        SELECT COUNT(DISTINCT p.id)
        FROM people p
        \(query.joinSQL)
        WHERE \(query.whereSQL)
        """

        var count = 0
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            for (index, value) in query.bindValues.enumerated() {
                bindText(statement, Int32(index + 1), value)
            }

            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return count
    }

    func fetchPeople(tagged tag: String) -> [PersonModel] {
        fetchPeople(matchingTags: [tag], partialMatch: false)
    }

    func fetchPeople(matchingTags tags: [String], partialMatch: Bool = false) -> [PersonModel] {
        let normalizedTags = tags.map(normalizeTag).filter { !$0.isEmpty }
        guard !normalizedTags.isEmpty else { return [] }

        let placeholders = Array(repeating: "?", count: normalizedTags.count).joined(separator: ", ")
        let predicate = partialMatch
            ? normalizedTags.map { _ in "pt.tag_normalized LIKE ?" }.joined(separator: " OR ")
            : "pt.tag_normalized IN (\(placeholders))"

        let sql = """
        SELECT DISTINCT p.id, p.name, p.company, p.role, p.tone, p.captured_at, p.last_contact, p.is_favorite, p.context, p.personal, p.followup, p.tags, p.apple_contact_identifier, p.apple_contact_last_synced_at, p.apple_contact_sync_checksum, p.apple_contact_snapshot_json
        FROM people p
        INNER JOIN person_tags pt ON pt.person_id = p.id
        WHERE p.deleted_at IS NULL
          AND (\(predicate))
        ORDER BY p.captured_at DESC
        """

        let bindValues = partialMatch ? normalizedTags.map { "%\($0)%" } : normalizedTags
        return fetchPeople(sql: sql, bindValues: bindValues)
    }

    private func peopleQueryParts(searchText: String, matchingTags tags: [String], partialTagMatch: Bool) -> (joinSQL: String, whereSQL: String, bindValues: [String]) {
        let normalizedTags = tags.map(normalizeTag).filter { !$0.isEmpty }
        var joins: [String] = []
        var predicates = ["p.deleted_at IS NULL"]
        var bindValues: [String] = []

        if !normalizedTags.isEmpty {
            joins.append("INNER JOIN person_tags pt ON pt.person_id = p.id")
            if partialTagMatch {
                predicates.append("(\(normalizedTags.map { _ in "pt.tag_normalized LIKE ?" }.joined(separator: " OR ")))")
                bindValues.append(contentsOf: normalizedTags.map { "%\($0)%" })
            } else {
                let placeholders = Array(repeating: "?", count: normalizedTags.count).joined(separator: ", ")
                predicates.append("pt.tag_normalized IN (\(placeholders))")
                bindValues.append(contentsOf: normalizedTags)
            }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let searchValue = "%\(trimmedSearch.lowercased())%"
            predicates.append("""
            (
                lower(p.name) LIKE ?
                OR lower(coalesce(p.company, '')) LIKE ?
                OR lower(coalesce(p.role, '')) LIKE ?
                OR lower(coalesce(p.tags, '')) LIKE ?
                OR lower(coalesce(p.apple_contact_snapshot_json, '')) LIKE ?
            )
            """)
            bindValues.append(contentsOf: Array(repeating: searchValue, count: 5))
        }

        return (
            joinSQL: joins.joined(separator: "\n"),
            whereSQL: predicates.joined(separator: "\n  AND "),
            bindValues: bindValues
        )
    }

    private func orderBySQL(for sortOption: PersonSortOption) -> String {
        switch sortOption {
        case .capturedRecent:
            return "p.captured_at DESC, lower(p.name) ASC"
        case .capturedOldest:
            return "p.captured_at ASC, lower(p.name) ASC"
        case .nameAZ:
            return "lower(substr(p.name, 1, instr(p.name || ' ', ' ') - 1)) ASC, lower(p.name) ASC"
        case .nameZA:
            return "lower(substr(p.name, 1, instr(p.name || ' ', ' ') - 1)) DESC, lower(p.name) DESC"
        case .lastContactRecent:
            return "coalesce(p.last_contact, 0) DESC, lower(p.name) ASC"
        }
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
        let sql = "SELECT id, person_id, text, transcription, extracted_json, created_at, is_followup FROM notes WHERE person_id = ? ORDER BY created_at DESC"
        var notes: [NoteModel] = []

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, personId, -1, nil)

            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let pId = String(cString: sqlite3_column_text(statement, 1))
                let text = String(cString: sqlite3_column_text(statement, 2))
                let transcription = sqlite3_column_text(statement, 3).map { String(cString: $0) }
                let extractedJson = decodeExtractedJson(columnText(statement, 4))
                let createdAt = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 5)))
                let isFollowUp = sqlite3_column_int(statement, 6) == 1

                var note = NoteModel(id: id, personId: pId, text: text, transcription: transcription, createdAt: createdAt)
                note.extractedJson = extractedJson
                note.isFollowUp = isFollowUp
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

    private func migrateCardsSchema() {
        addColumnIfMissing(table: "cards", column: "name", definition: "TEXT NOT NULL DEFAULT ''")
        addColumnIfMissing(table: "cards", column: "nickname", definition: "TEXT")
        fixMultipleDefaults()
    }

    private func fixMultipleDefaults() {
        let sql = """
        SELECT id FROM cards WHERE deleted_at IS NULL AND is_default = 1 ORDER BY created_at ASC LIMIT -1 OFFSET 1
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let cardId = columnText(statement, 0) {
                    let updateSQL = "UPDATE cards SET is_default = 0 WHERE id = ?"
                    var updateStatement: OpaquePointer?
                    if sqlite3_prepare_v2(db, updateSQL, -1, &updateStatement, nil) == SQLITE_OK {
                        bindText(updateStatement, 1, cardId)
                        sqlite3_step(updateStatement)
                    }
                    sqlite3_finalize(updateStatement)
                }
            }
        }
        sqlite3_finalize(statement)
    }

    private func backfillPersonTags() {
        let sql = """
        SELECT id, tags
        FROM people
        WHERE deleted_at IS NULL
          AND tags IS NOT NULL
          AND id NOT IN (SELECT DISTINCT person_id FROM person_tags)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                guard let personId = columnText(statement, 0) else { continue }
                replaceTags(for: personId, tags: decodeTags(columnText(statement, 1)))
            }
        }

        sqlite3_finalize(statement)
    }

    private func replaceTags(for personId: String, tags: [String]) {
        let deleteSQL = "DELETE FROM person_tags WHERE person_id = ?"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteSQL, -1, &deleteStatement, nil) == SQLITE_OK {
            bindText(deleteStatement, 1, personId)
            sqlite3_step(deleteStatement)
        }
        sqlite3_finalize(deleteStatement)

        let cleanedTags = Array(Set(tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }))
        guard !cleanedTags.isEmpty else { return }

        let insertSQL = "INSERT OR REPLACE INTO person_tags (person_id, tag, tag_normalized) VALUES (?, ?, ?)"
        for tag in cleanedTags {
            var insertStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, insertSQL, -1, &insertStatement, nil) == SQLITE_OK {
                bindText(insertStatement, 1, personId)
                bindText(insertStatement, 2, tag)
                bindText(insertStatement, 3, normalizeTag(tag))
                sqlite3_step(insertStatement)
            }
            sqlite3_finalize(insertStatement)
        }
    }

    private func fetchPeople(sql: String, bindValues: [String]) -> [PersonModel] {
        var people: [PersonModel] = []
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            for (index, value) in bindValues.enumerated() {
                bindText(statement, Int32(index + 1), value)
            }

            while sqlite3_step(statement) == SQLITE_ROW {
                if let person = personFromCurrentRow(statement) {
                    people.append(person)
                }
            }
        }

        sqlite3_finalize(statement)
        return people
    }

    private func personFromCurrentRow(_ statement: OpaquePointer?) -> PersonModel? {
        let rawId = columnText(statement, 0)
        guard let id = rawId, !id.isEmpty else {
            return nil
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
        return person
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

    private func normalizeTag(_ tag: String) -> String {
        tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func encodeExtractedJson(_ extractedJson: [String: String]) -> String? {
        guard !extractedJson.isEmpty,
              let data = try? JSONEncoder().encode(extractedJson),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    private func decodeExtractedJson(_ json: String?) -> [String: String] {
        guard let json,
              let data = json.data(using: .utf8),
              let extractedJson = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }

        return extractedJson
    }

    // MARK: - Card Operations

    func insertCard(_ card: CardModel) {
        let sql = """
        INSERT INTO cards (id, name, nickname, first_name, last_name, email, phone, avatar, role, company, bio, tagline, location, timezone, pronouns, social_links, payment_links, chat_apps, is_default, shared_publicly, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, card.id)
            bindText(statement, 2, card.name)
            bindText(statement, 3, card.nickname)
            bindText(statement, 4, card.firstName)
            bindText(statement, 5, card.lastName)
            bindText(statement, 6, card.email)
            bindText(statement, 7, card.phone)
            bindText(statement, 8, card.avatar)
            bindText(statement, 9, card.role)
            bindText(statement, 10, card.company)
            bindText(statement, 11, card.bio)
            bindText(statement, 12, card.tagline)
            bindText(statement, 13, card.location)
            bindText(statement, 14, card.timezone)
            bindText(statement, 15, card.pronouns)
            bindText(statement, 16, encodeNestedJSON(card.socialLinks))
            bindText(statement, 17, encodeNestedJSON(card.paymentLinks))
            bindText(statement, 18, encodeNestedJSON(card.chatApps))
            sqlite3_bind_int(statement, 19, card.isDefault ? 1 : 0)
            sqlite3_bind_int(statement, 20, card.sharedPublicly ? 1 : 0)
            sqlite3_bind_int64(statement, 21, Int64(card.createdAt.timeIntervalSince1970))
            sqlite3_bind_int64(statement, 22, Int64(card.updatedAt.timeIntervalSince1970))

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✓ Card inserted: \(card.name)")
            }
        }
        sqlite3_finalize(statement)
    }

    func updateCard(_ card: CardModel) {
        let sql = """
        UPDATE cards SET
            name = ?, nickname = ?, first_name = ?, last_name = ?, email = ?, phone = ?, avatar = ?,
            role = ?, company = ?, bio = ?, tagline = ?, location = ?,
            timezone = ?, pronouns = ?, social_links = ?, payment_links = ?,
            chat_apps = ?, is_default = ?, shared_publicly = ?, updated_at = ?
        WHERE id = ? AND deleted_at IS NULL
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, card.name)
            bindText(statement, 2, card.nickname)
            bindText(statement, 3, card.firstName)
            bindText(statement, 4, card.lastName)
            bindText(statement, 5, card.email)
            bindText(statement, 6, card.phone)
            bindText(statement, 7, card.avatar)
            bindText(statement, 8, card.role)
            bindText(statement, 9, card.company)
            bindText(statement, 10, card.bio)
            bindText(statement, 11, card.tagline)
            bindText(statement, 12, card.location)
            bindText(statement, 13, card.timezone)
            bindText(statement, 14, card.pronouns)
            bindText(statement, 15, encodeNestedJSON(card.socialLinks))
            bindText(statement, 16, encodeNestedJSON(card.paymentLinks))
            bindText(statement, 17, encodeNestedJSON(card.chatApps))
            sqlite3_bind_int(statement, 18, card.isDefault ? 1 : 0)
            sqlite3_bind_int(statement, 19, card.sharedPublicly ? 1 : 0)
            sqlite3_bind_int64(statement, 20, Int64(Date().timeIntervalSince1970))
            bindText(statement, 21, card.id)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("✓ Card updated: \(card.name)")
            }
        }
        sqlite3_finalize(statement)
    }

    func deleteCard(cardId: String) {
        let sql = "UPDATE cards SET deleted_at = ? WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, Int64(Date().timeIntervalSince1970))
            bindText(statement, 2, cardId)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchCards() -> [CardModel] {
        let sql = """
        SELECT id, name, nickname, first_name, last_name, email, phone, avatar, role, company, bio, tagline, location, timezone, pronouns, social_links, payment_links, chat_apps, is_default, shared_publicly, created_at, updated_at
        FROM cards
        WHERE deleted_at IS NULL
        ORDER BY is_default DESC, created_at DESC
        """

        var cards: [CardModel] = []
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                guard let card = cardFromRow(statement) else { continue }
                cards.append(card)
            }
        }
        sqlite3_finalize(statement)
        return cards
    }

    func setDefaultCard(cardId: String) {
        let clearSQL = "UPDATE cards SET is_default = 0 WHERE deleted_at IS NULL"
        executeSQL(clearSQL)

        let setSQL = "UPDATE cards SET is_default = 1 WHERE id = ? AND deleted_at IS NULL"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, setSQL, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, 1, cardId)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    private func cardFromRow(_ statement: OpaquePointer?) -> CardModel? {
        guard let id = columnText(statement, 0),
              let name = columnText(statement, 1),
              let firstName = columnText(statement, 3),
              let email = columnText(statement, 5),
              let role = columnText(statement, 8),
              let company = columnText(statement, 9) else {
            return nil
        }

        var card = CardModel(
            id: id,
            name: name,
            nickname: columnText(statement, 2),
            firstName: firstName,
            lastName: columnText(statement, 4),
            email: email,
            phone: columnText(statement, 6),
            avatar: columnText(statement, 7),
            role: role,
            company: company,
            bio: columnText(statement, 10),
            tagline: columnText(statement, 11),
            location: columnText(statement, 12),
            timezone: columnText(statement, 13),
            pronouns: columnText(statement, 14),
            socialLinks: decodeNestedJSON(columnText(statement, 15)) ?? [],
            paymentLinks: decodeNestedJSON(columnText(statement, 16)) ?? [],
            chatApps: decodeNestedJSON(columnText(statement, 17)) ?? [],
            isDefault: sqlite3_column_int(statement, 18) == 1,
            sharedPublicly: sqlite3_column_int(statement, 19) == 1
        )

        card.createdAt = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 20)))
        card.updatedAt = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(statement, 21)))

        return card
    }

    private func encodeNestedJSON<T: Encodable>(_ value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return json
    }

    private func decodeNestedJSON<T: Decodable>(_ json: String?) -> T? {
        guard let json,
              let data = json.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func clearAllData() {
        let tables = ["people", "notes", "contacts", "threads", "shares", "relationships", "cards", "users"]
        for table in tables {
            let sql = "DELETE FROM \(table)"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
                sqlite3_step(statement)
            }
            sqlite3_finalize(statement)
        }
    }

    deinit {
        sqlite3_close(db)
    }
}

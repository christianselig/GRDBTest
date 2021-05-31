//
//  Persistence.swift
//  Grada
//
//  Created by Christian Selig on 2021-05-29.
//

import UIKit
import GRDB

var dbQueue: DatabaseQueue!

class DatabaseManager {
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("createSubreddit") { db in
            try db.create(table: "subreddit") { t in
                t.column("id", .text).primaryKey()
                t.column("subscribers", .integer).notNull()
            }
            
            try! db.create(index: "byID", on: "subreddit", columns: ["id"], unique: true)
        }
        
        return migrator
    }

    
    static func setup(for application: UIApplication) throws {
        let fileManager = FileManager()
        let folderURL = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("database", isDirectory: true)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let dbURL = folderURL.appendingPathComponent("db.sqlite")

        dbQueue = try DatabaseQueue(path: dbURL.path)
        try migrator.migrate(dbQueue)
    }
}

struct Subreddit: Identifiable, Hashable {
    var id: String
    var subscribers: Int64
}

extension Subreddit: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let subscribers = Column(CodingKeys.subscribers)
    }
    
    static func askMatches() -> QueryInterfaceRequest<Subreddit> {
        return Subreddit.filter(Columns.id.like("ask%"))
    }
}

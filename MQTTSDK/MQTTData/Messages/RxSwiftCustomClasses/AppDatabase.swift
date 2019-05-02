import RxSwift
import RxGRDB
import GRDB


/// A type responsible for initializing the application database.
///
/// See AppDelegate.setupDatabase()
struct AppDatabase {
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabasePool {
        // Connect to the database
        // See https://github.com/groue/GRDB.swift/#database-connections
        let dbPool = try DatabasePool(path: path)
        
        // Use DatabaseMigrator to define the database schema
        // See https://github.com/groue/GRDB.swift/#migrations
        try migrator.migrate(dbPool)
        
        return dbPool
    }
    
    /// The DatabaseMigrator that defines the database schema.
    // See https://github.com/groue/GRDB.swift/#migrations
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1.0") { db in
            try db.create(table: "chatMessage") { t in
                t.autoIncrementedPrimaryKey(kId)
                t.column(kTextMessage, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(kDateTime, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            }
        }
        
        migrator.registerMigration("v1.1.0") { db in
            try db.create(table: MqttMessageModal.DataBaseTableName) { t in
                t.autoIncrementedPrimaryKey(kId)
                t.column(MqttMessageModal.kMessageId, .text).notNull()
                t.column(MqttMessageModal.kMessageType, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kMessage, .text).notNull()
                t.column(MqttMessageModal.kFullName, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kProjectName, .text).notNull()
                t.column(MqttMessageModal.kAction, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kOriginalFileName, .text).notNull()
                t.column(MqttMessageModal.kType, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kRoomId, .text).notNull()
                t.column(MqttMessageModal.kProfilePictureUrl, .text).notNull()
                t.column(MqttMessageModal.kEmailId, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kLoginUserId, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kCreatedDate, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kIsExport, .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column(MqttMessageModal.kMessageDate, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            }//
        }
        
        return migrator
    }
}

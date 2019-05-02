//
//  ChatMessage.swift
//  MqttChatDemo
//
//  Created by Jayesh on 05/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import Foundation
import GRDB

let kTextMessage = "chat_message"
let kDateTime = "date_time"
let kId = "id"


// A player
struct chatMessage: Codable {
    var id: Int64?
    var chat_message: String
    var date_time: String
}

// Implementation is automatically derived from Codable.
extension chatMessage: FetchableRecord { }

// Adopt MutablePersistable so that we can create/update/delete players in the database.
extension chatMessage: MutablePersistableRecord {
    static let databaseTableName = "chatMessage"
    
    enum Columns: String, ColumnExpression
    {
        case id, chat_message, date_time
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

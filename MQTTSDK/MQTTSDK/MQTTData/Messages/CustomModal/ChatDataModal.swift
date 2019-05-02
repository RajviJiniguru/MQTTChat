//
//  ChatDataModal.swift
//  MqttChatDemo
//
//  Created by Jayesh on 06/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import Foundation
import GRDB


struct chatDataModal : Codable
{
    var id: Int64?
    var message_id: String
    var message_type: String
    var message: String
    var full_name: String
    var action: String
    var type: String
    var project: String
    var original_file_name: String
    var room_id: String
    var profile_picture_url: String
    var email: String
    var login_user_id: String
    var created_at: String
    var is_export : String
    var message_date : String
    
}
extension chatDataModal: FetchableRecord
{
    
}

// Adopt MutablePersistable so that we can create/update/delete players in the database.
extension chatDataModal: MutablePersistableRecord
{
    static let databaseTableName = MqttMessageModal.DataBaseTableName
    
    enum Columns: String, ColumnExpression
    {
        case id,
        message_id,
        message_type,
        message,full_name,
        action,
        type,project,
        original_file_name,
        room_id,
        profile_picture_url,
        email,
        login_user_id,
        is_export,
        message_date
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}


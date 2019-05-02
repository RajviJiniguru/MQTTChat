//
//  ClientInformationModal.swift
//  thecareportal
//
//  Created by Jayesh on 06/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import SwiftyJSON
import FMDB

class ClientInformationModal {

    // Property Declaration
    var client_id : String?
    var client_name : String?
    var client_profile_picture : String?
    var dnar : String?
    var chatengine_room_id : String?
    var chat_room_name : String?
    
    public required init(resultset : FMResultSet) {
        // Manage Data
        client_id = resultset.string(forColumn: DatabaseFieldName.client_id)
        client_name = resultset.string(forColumn: "name")
        client_profile_picture = resultset.string(forColumn: DatabaseFieldName.client_profile_picture)
        dnar = resultset.string(forColumn: "dnar")
        chatengine_room_id =  resultset.string(forColumn: "chatengine_room_id")
    }
    init() {
        
    }
}

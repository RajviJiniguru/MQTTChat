//
//  UserInformarion.swift
//  thecareportal
//
//  Created by Jayesh on 08/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInformarion: NSObject,Codable{
   
    // Property Declaration
    var email : String?
    var first_name : String?
    var last_name : String?
    var mobile_no : String?
    var user_id : String?
    var user_type : String?
    var room_name : String?
    var room_type : String?
    var chatengine_room_id : String?
    var unread_message_count : String?
    
    public required init(json : JSON) {
        email = json["email"].string
        first_name = json["first_name"].string
        last_name = json["last_name"].string
        mobile_no = json["mobile_no"].string
        user_id = json["user_id"].string
        user_type = json["user_type"].string
    }
    
    override init(){
        
    }
}

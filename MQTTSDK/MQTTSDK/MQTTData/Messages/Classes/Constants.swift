//
//  Constants.swift
//  MqttChatDemo
//
//  Created by Jayesh on 12/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import Foundation

/*
 HOST : 52.56.187.203
 username : homecare
 Password : WtfASD9bxLfSdSAjJwmyrALMLP4CGNrT
 PORT = 1883 OR 1884
 */

let kMessage = "Message"
let kName = "Name"
let kprofile_picture_url = "profile_picture_url"
let kDate = "Date"
//let kLoginUserId = "59b00f51-d805-9d3f-dbd3-5b9a146f1bfe"
//let kLoginUserId = "104428f4-86f4-b817-9ce5-5a4a07b08ed5"
let kLoginUserId = "1"
let host_url = "52.56.187.203"
let port_number: UInt16 = 1883
let clientID = "1df5r"
//let mqttUsername = "homecare"
//let mqttPassword = "WtfASD9bxLfSdSAjJwmyrALMLP4CGNrT"
let ChannelName : String = "b31fbc66-7ad4-e380-3ade-5b9a10604aad"
//let ChannelName : String = "1"
let kStatusCode : String = "statusCode"

struct WS_MqttAPI {
    
    static let BaseUrl = "http://192.168.10.221:6161/api/v1/"
    
    static var FetchUserMessages: String{
        return BaseUrl  + "fetch-user-messages"
    }
    
    static var ChatImageUpload: String
    {
        return BaseUrl  + "chat-image-upload"
    }
    
    //http://192.168.10.221:6161/api/v1/
}

struct APIParam {
    
    // key Param
    static var kDeviceId : String = "device_id"
    static var kPushRegistrationId : String = "push_registration_id"
    static var kAppVersion : String = "app_version"
    static var kDeviceType : String = "device_type"
    static var kOsVersion : String = "os_version"
    static var kUserId : String = "user_id"
    static var kLastMessageDate : String = "last_message_date"
    static var kStatusSuccess : Int = 200
    
    // value Param
    
    static var kDeviceTypeValue : String = "ANDROID"
    static var kAppVersionValue : String = "0.1"
    static var kDeviceIdValue : String = "werteyurw764"
    static var kPushRegistrationIdValue : String = "87r987rhd"
    static var kOsVersionValue : String = "8.0"
    
}


struct MqttMessageModal {
  
    static var DataBaseTableName : String = "chatDataModal"
    
    static var kMessageId : String = "message_id"
    static var kMessageType : String = "message_type"
    static var kMessage : String = "message"
    static var kFullName : String = "full_name"
    static var kAction : String = "action"
    static var kType : String = "type"
    static var kProjectName : String = "project"
    static var kOriginalFileName : String = "original_file_name"
    static var kRoomId : String = "room_id"
    static var kProfilePictureUrl : String = "profile_picture_url"
    static var kEmailId : String = "email"
    static var kLoginUserId : String = "login_user_id"
    static var kIsExport : String = "is_export"
    static var kCreatedDate : String = "created_at"
    static var kMessageDate : String = "message_date"
    
    
}

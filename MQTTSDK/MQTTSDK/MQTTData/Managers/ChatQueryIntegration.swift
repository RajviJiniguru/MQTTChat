//
//  ChatQueryIntegration.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 24/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

extension DBManager{
    
    static func getUserNameByUserId(userId : String?) -> (userName : String?,userProfileImage:String?){
        
        // Here you will get rocket chat email id and then after we will execute a query in master database to get username
        if DBManager.sharedInstance().openMasterDatabase(){
            
            if let userId = userId ,let database = DBManager.sharedInstance().masterDatabase
            {
                if(database.open()) {
                    
                    let queryString = "SELECT full_name,profile_picture FROM hc_user_profile WHERE user_id = '\(userId)'"
                    
                        //let queryString = "SELECT full_name,profile_picture FROM hc_user_profile WHERE chatengine_user_id = '\(userId)'"
                    
                    do{
                        let results = try database.executeQuery(queryString, values: nil)
                        
                        while results.next(){
                            return (results.string(forColumn: "full_name"),results.string(forColumn: "profile_picture"))
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        return (nil,nil)
    }
    
    
    static func getRoomId(userId : String? , roomType : String?) -> [UserInformarion]? {
        
        // SharedManager.sharedInstance.userProfile.user_id
        
        // Here you will get rocket chat email id and then after we will execute a query in master database to get username
        
        if let userId = userId,let roomType = roomType,let database = DBManager.sharedInstance().masterDatabase
       // if let roomType = roomType,let database = DBManager.sharedInstance().masterDatabase

        {
            if(database.open()){
                
            var queryString : String!
                
                if roomType == "GENERAL"{
                      queryString = "SELECT * FROM hc_chat_rooms where room_type = '\(roomType)' order by created_at"
                }
                else{
                queryString = "SELECT * FROM hc_chat_rooms \n" +
                "where room_id in(select room_id from hc_chat_room_users where user_id = '\(userId)' and deleted_at is null) and room_type = '\(roomType)' order by created_at"
                }
                
                //==== ANDROID ======
//                queryString = "select *, (select count(*) from chatDataModal where room_id = rooms.room_id) as unread_count from (select * from hc_chat_rooms where room_type = '\(roomType)' order by display_order) as rooms"
             
                
           //     queryString = "SELECT * FROM hc_chat_rooms where room_type = '\(roomType)' order by created_at"
            
                do{
                    
                    let results = try database.executeQuery(queryString, values: nil)
                    
              
                    var arrResult = [UserInformarion]()
                    
                    while results.next(){
                        
                        if let roomName = results.string(forColumn: "room_name"),let roomType = results.string(forColumn: "room_type"),let chatEngineRoomId = results.string(forColumn: "room_id") {
                            
                            let userInformation = UserInformarion()
                            userInformation.room_name = roomName
                            userInformation.room_type = roomType
                            userInformation.chatengine_room_id = chatEngineRoomId
                            
                            arrResult.append(userInformation)
                        }
                    }
                    
                    return arrResult
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    static func getRoomIdAll() -> [[String:Any]]? {
        if let database = DBManager.sharedInstance().masterDatabase{
            if(database.open()){
                var queryString : String!
                queryString = "SELECT * FROM hc_chat_rooms"
                do{
                    let results = try database.executeQuery(queryString, values: nil)
                    var arrResult =  [[String : Any]]()
                    while results.next(){
                        let roomInfo : [String : Any] = ["room_id": results.string(forColumn: "room_id")!]
                        arrResult.append(roomInfo)
                    }
                    return arrResult
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }
    static func getUserProfile(userId : String? ) -> String?{
        
        if let userId = userId, let database = DBManager.sharedInstance().masterDatabase{
        if(database.open()){
            var queryString : String!
            queryString = "select profile_picture from hc_user_profile where user_id = '\(userId)'"
            do{
                let results = try database.executeQuery(queryString, values: nil)
               
                while results.next(){
                    return (results.string(forColumn: "profile_picture"))
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
        return nil
    }
    static func getClientRoomDetailsById(clientId : String?) -> String?{
        
        // Here you will get rocket chat email id and then after we will execute a query in master database to get username
        
        if let clientId = clientId,let database = DBManager.sharedInstance().masterDatabase
        {
            if(database.open()){
                
                let queryString = "SELECT chatengine_room_id FROM hc_clients WHERE client_id = '\(clientId)'"
                do{
                    let results = try database.executeQuery(queryString, values: nil)
                    
                    while results.next(){
                        return (results.string(forColumn: "chatengine_room_id"))
                    }
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func getClientInfo(userId : String?) -> (chatengine_room_id : String?,room_name:String?)?{
        
        if let userId = userId,let database = DBManager.sharedInstance().masterDatabase
        {
            if(database.open()){
                
                let queryString = "SELECT chatengine_room_id,room_name FROM hc_chat_rooms \n" +
                "where chatengine_room_id in(select chatengine_room_id from hc_clients where client_id = '\(userId)' and deleted_at is null) order by created_at"
                
                do{
                    let results = try database.executeQuery(queryString, values: nil)
                    
                    while results.next(){
                        return (results.string(forColumn: "chatengine_room_id"),
                                results.string(forColumn: "room_name"))
                    }
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        return (nil,nil)
    }
    
    static func getRoomIdForDefaultCarerChat(loggedInUserId : String?) -> String?{
        
        if let loggedInUserId = loggedInUserId,let database = DBManager.sharedInstance().masterDatabase{
            
            if(database.open()){
                
                let queryString = "SELECT chatengine_room_id FROM hc_user_profile WHERE user_id = '\(loggedInUserId)'"
                
                do{
                    let results = try database.executeQuery(queryString, values: nil)
                    
                    while results.next(){
                        return (results.string(forColumn: "chatengine_room_id"))
                    }
                    
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
}

//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

struct MessageManager {
    static let initialHistorySize = 30
    static let laterHistorySize = 60
}

let kBlockedUsersIndentifiers = "kBlockedUsersIndentifiers"

extension MessageManager {

    static var blockedUsersList = UserDefaults.standard.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []

    static func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping MessageCompletionObjectsList<Message>) {
        var lastDate: Any!
//        var size: Int

        if let lastMessageDate = lastMessageDate {
            lastDate = ["$date": lastMessageDate.timeIntervalSince1970 * 1000]
            // size = laterHistorySize // Commented code
        } else {
            lastDate = NSNull()
            // size = initialHistorySize // Commented code
        }

        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", lastDate, 0 , [
                "$date": Date().timeIntervalSince1970 * 1000
            ]]
        ] as [String: Any]

        let validMessages = List<Message>()

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            let list = response.result["result"]["messages"].array

            let subscriptionIdentifier = subscription.identifier
            
            Realm.execute({ (realm) in
                guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ?? "") else { return }

                list?.forEach { object in
                    let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.subscription = detachedSubscription
                    })
                    
                    if let currentRoomId = MessageVC.lastSelectedRoomId{
                        
                        if(currentRoomId == message.rid){
                            message.isRead = 1
                        }
                    }
                    
                    message.isExport = 1
                    realm.add(message, update: true)

                    if !message.userBlocked {
                        validMessages.append(message)
                    }
                }
            }, completion: {
                Helper.setDatePREF(Date.serverDate, key: UserDefaultsConstant.PREF_LAST_SYNC_MSG_DATE)
                completion(Array(validMessages))
            })
        }
    }

    static func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "id": eventName,
            "params": [eventName, false]
        ] as [String: Any]
        
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            var object = response.result["fields"]["args"][0]
            let subscriptionIdentifier = subscription.identifier
            
            print(response.result)
            
            if let fileObj = object["file"].dictionary{
               
                if let fileId = fileObj["_id"]?.string{
                   
                    Realm.execute({ (realm) in
                        if let lastMessage = realm.objects(Message.self).filter("text == '\(fileId)'").last {

                            if(fileId == lastMessage.text){
                                
                                lastMessage.text = "Marked For Deletion Image"
                                lastMessage.markedForDeletion = true
                                realm.add(lastMessage, update: true)
                                
                                addNewMessage(object: object, subscriptionIdentifier: subscriptionIdentifier ?? "")
                                
                                return
                            }
                            
                        }else{
                           addNewMessage(object: object, subscriptionIdentifier: subscriptionIdentifier ?? "")
                        }
                    })
                }
            }else{
              addNewMessage(object: object, subscriptionIdentifier: subscriptionIdentifier ?? "")
            }
        }
    }
    
    static func addNewMessage(object : JSON ,subscriptionIdentifier : String){
        
        Realm.execute({ (realm) in
            guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionIdentifier ) else { return }
            
            let message = Message.getOrCreate(realm: realm, values: object, updates: { (object) in
                object?.subscription = detachedSubscription
            })
            
            if let currentRoomId = MessageVC.lastSelectedRoomId{
                
                if(currentRoomId == message.rid){
                    message.isRead = 1
                }
            }
            
            message.isExport = 1
            realm.add(message, update: true)
        })
    }
    
    static func report(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "reportMessage",
            "params": [messageIdentifier, "Message reported by user."]
        ] as [String: Any]

        SocketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
    static func pinMessage(_ message: Message,pinnedPriority : Int,completion: @escaping MessageCompletion) {
        
        guard let messageIdentifier = message.identifier else { return }
        var dictonary : [String : Any] = [:]
        if let data = message.jsonResponse.data(using: .utf8){
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
            } catch(let error)
            {
                print(error.localizedDescription)
            }
        }
        
        
        let request = [
            "msg": "method",
            "method": "pinMessage",
            "params": [dictonary,nil,pinnedPriority]
            ] as [String: Any]
        SocketManager.send(request, completion: completion)
    }

    static func pin(_ message: Message, completion: @escaping MessageCompletion) {
        
        guard let messageIdentifier = message.identifier else { return }
        
   
        
        let request = [
            "msg": "method",
            "method": "pinMessage",
            "params": ["rid": message.rid, "_id": messageIdentifier ]
        ] as [String: Any]

        SocketManager.send(request, completion: completion)
    }

    static func unpin(_ message: Message, completion: @escaping MessageCompletion) {
        guard let messageIdentifier = message.identifier else { return }

        let request = [
            "msg": "method",
            "method": "unpinMessage",
            "params": [ ["rid": message.rid, "_id": messageIdentifier ] ]
        ] as [String: Any]

        SocketManager.send(request, completion: completion)
    }

    static func blockMessagesFrom(_ user: User, completion: @escaping VoidCompletion) {
        guard let userIdentifier = user.identifier else { return }

        var blockedUsers: [String] = UserDefaults.standard.value(forKey: kBlockedUsersIndentifiers) as? [String] ?? []
        blockedUsers.append(userIdentifier)
        UserDefaults.standard.setValue(blockedUsers, forKey: kBlockedUsersIndentifiers)
        self.blockedUsersList = blockedUsers

        Realm.execute({ (realm) in
            let messages = realm.objects(Message.self).filter("user.identifier = '\(userIdentifier)'")

            for message in messages {
                message.userBlocked = true
            }

            realm.add(messages, update: true)

            DispatchQueue.main.async {
                completion()
            }
        })
    }

}

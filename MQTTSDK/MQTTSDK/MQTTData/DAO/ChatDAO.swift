////
////  ChatDAO.swift
////  thecareportal
////
////  Created by Anil Kukadeja on 08/12/17.
////  Copyright © 2017 Jiniguru. All rights reserved.
////
//
import UIKit
import RealmSwift

//
class ChatDAO: NSObject {
    
    static let _sharedInstance = ChatDAO()
    
    var messagesToken: NotificationToken!

    class func sharedInstance() -> ChatDAO {
        return _sharedInstance
    }
    
    func loginWithEmailAndPassword(email : String,password : String){
        
        AuthManager.auth(email, password: password) { (response) in
            
            if response.isError() {
                
                if let error = response.result["error"].dictionary {
                    // User is using 2FA
                     print("Login error",error.description)
//                    Helper.showOKAlert(onVC: self, title: localized("error.socket.default_error_title"), message: error["message"]?.string ?? localized("error.socket.default_error_message"))
                    
                }
               
                return
            }
            
            if let auth = AuthManager.isAuthenticated(){
                SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                    AuthSettingsManager.updatePublicSettings(auth, completion: { _ in
                        self.loadHistoryFromRemote(date: nil)
                    })
                })
            }
            
       }
    }
    
    func subscribeLoggedInUser(){
        
        if let auth = AuthManager.isAuthenticated() {
            AuthManager.persistAuthInformation(auth)
            
            AuthManager.resume(auth, completion: { [weak self] response in
                
                self?.loadHistoryFromRemote(date: nil)
                self?.addMessageQueryRealmNotification()
            })
        }
    }
    
    func loadHistoryFromRemote(date: Date?) {
        
        guard let realm = Realm.shared else { return }
        
        let subscriptions = realm.objects(Subscription.self).sorted(byKeyPath: "lastSeen", ascending: false)
        
//        let messageQuery = realm.objects(Message.self).filter("text == 'Updated and removed attachement'")
//        
//        Realm.executeOnMainThread({ (realm) in
//            realm.delete(messageQuery)
//        })
//        
        for subscription in subscriptions.enumerated(){
            
            MessageManager.changes(subscription.element)
            MessageManager.getHistory(subscription.element, lastMessageDate: nil, completion: { (messsage) in
                
            }) 
        }
    }
    
    func addMessageQueryRealmNotification(){
        
        guard let realm = Realm.shared else { return }
        
        let messageQuery = realm.objects(Message.self).filter("isExport == 0")
        
        if(!messageQuery.isInvalidated){
            
            messagesToken = messageQuery.observe{ [unowned self] changes in
                
                switch changes {
                    
                case .initial :
                    
                    for message in messageQuery.enumerated(){
                        self.syncOfflineMessagesToServer(messageToBeSync: message.element)
                    }
                    
                case .update(_, _, let insertions,_) :
                    
                    if insertions.count > 0 {
                        
                        for insertion in insertions {
                            guard insertion < messageQuery.count else { continue }
                            let newMessage = Message(value: messageQuery[insertion])
                            self.syncOfflineMessagesToServer(messageToBeSync: newMessage)
                        }
                        
                    }
                    
                default :
                    print("return")
                }
            }
        }
    }
    
    func syncOfflineMessagesToServer(messageToBeSync : Message){
        
        // This method will sync and push all the messages who has a flag isExport = 0 to server when internet connection is available
        
        if(messageToBeSync.type == .image){
            getImageFromDocumentDirectoryToUpload(messageToBeSync: messageToBeSync)
        }else{
            
            SubscriptionManager.sendTextMessage(messageToBeSync) { response in
                Realm.executeOnMainThread({ (realm) in
                    messageToBeSync.temporary = false
                    MessageTextCacheManager.shared.update(for: messageToBeSync, completion: nil)
                    //                messageToBeSync.map(response.result["result"], realm: realm)
                    
                    realm.add(messageToBeSync, update: true)
                })
            }
        }
        
    }
    
    func getImageFromDocumentDirectoryToUpload(messageToBeSync : Message){
        
        if let documentDirectory = DBManager._sharedInstance.documentDirecotryPath{
            
            print("getImageFromDocumentDirectoryToUpload")
            
            for attachment in messageToBeSync.attachments.enumerated(){
                
                let imageName = documentDirectory.appendingPathComponent(attachment.element.title)
                if let imageToUpload = UIImage(contentsOfFile: imageName.path){
                    
                    resizeOriginalImageAndSendToServer(messageToBeSync: messageToBeSync, image: imageToUpload, subscription: messageToBeSync.subscription, successCompletionHandler: { (result) in
                        
                        print(result)
                        
                        DBManager._sharedInstance.deleteFilesAtDocumentDirectory(fileUrl: imageName.absoluteURL)
                    })
                }

            }
        }
    }
    
    func resizeOriginalImageAndSendToServer(messageToBeSync : Message,image : UIImage,subscription : Subscription,successCompletionHandler:  @escaping successCallback){
        
        let resizedImage = image.resizeWith(width: 1024) ?? image
        var file: FileUpload?
        
//        guard let imageData = image.jpegData(resizedImage, 0.9) else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }

        file = UploadHelper.file(
            for: imageData,
            name: "\(String.random().components(separatedBy: ".").first ?? "image").jpeg",
            mimeType: "image/jpeg"
        )
        
        if let file = file{
            
            UploadManager.shared.upload(file: file, subscription: subscription, progress: { (progress) in
                // We currently don't have progress being called.
            }, completion: { (response, error) in
                    successCompletionHandler("")
                }, completionFileId: { (fileId) in
                    
                    Realm.executeOnMainThread({ (realm) in
                        messageToBeSync.text = fileId
                        realm.add(messageToBeSync, update: true)
                    })
                    
            })
        }
    }
    
    func updateMessageMarkAsAReadCount(rid : String){
        
        // set is_read = 0 to 1 for selected room id
        
        guard let realm = Realm.shared else { return }
        
        let messages = realm.objects(Message.self).filter("rid == '\(rid)' AND isRead == 0")
        
        try! realm.write {
            messages.setValue(1, forKeyPath: "isRead")
        }
    }
    
    func removeCompletionBlocksIfNetworkConnectionGetsLost(){
        
        print("removeCompletionBlocksIfNetworkConnectionGetsLost")
        
        SocketManager.sharedInstance.events = [:]
        messagesToken?.invalidate()
     //   SocketManager.sharedInstance.socket?.disconnect()
    }
    
    func reconnect(){
        
        print("reconnect")
        ChatDAO._sharedInstance.subscribeLoggedInUser()
    }
}

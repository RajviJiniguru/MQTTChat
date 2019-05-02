//
//  MQTTChat.swift
//  thecareprtal
//
//  Created by Jayesh on 31/08/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import UIKit
import CocoaMQTT

typealias mqttConnectionCheckEstablished = ((Bool) -> ())?
/*
<<user_id>>_store-dongle-data
<<user_id>>_retrieve-dongle-data
*/
//MQTT SERVER INFORMATION
//MQTT HOST : 192.168.10.240
//USERNAME : ashwin
//PASSWORD : ashwin123
//MQTT PORT: 9001 or 1883

//let mqttNonSSLHost_url = "192.168.10.240" //"35.176.17.24"
//let mqttNonSSLPort_number: UInt16 = 1883

let mqttSSL_Host_Url = "52.56.187.203"// "192.168.10.240"//"192.168.10.221"  //"ev-tech.uk"
let mqttSSL_Port_Number : UInt16 =  1883 //1884
let mqttUsername = "homecare"
let mqttPassword = "WtfASD9bxLfSdSAjJwmyrALMLP4CGNrT"
//let mqttUsername = "ashwin"
//let mqttPassword = "ashwin123"
//let mqttUsername =  "tushar"//"EvTechDongleData"
//let mqttPassword =  "admin" //"h2ubavdU5j6cFhg38W5sdZnz9J99NDCk"
var arrOfRooms =  [[String : Any]]()
let mqttChannelRetriveSubcribe  =  "b31fbc66-7ad4-e380-3ade-5b9a10604aad" //"_retrieve-dongle-data"
let mqttChannelName : String =  "b31fbc66-7ad4-e380-3ade-5b9a10604aad"//"_store-dongle-data" // ==  topic_id
let mqttProjectName : String = "EV-APP"
let mqttDongleType : String = "CARISTA"
let mqttDongleCurrentConnection : String = "BLUETOOTH" // WIFI

typealias connectionResponse = (String, Error?) -> Void

protocol LoginWithMqttDelegate: class
{
    func didSucceedToSignInFor(getEvDongleData: [String : Any])
    func didGetCurrentState(strMessage: String)
    func didFailToSignIn(strMessage: String)
}

class MQTTChat: NSObject
{
    // MARK: - Properties
    static let sharedInstance = MQTTChat()
    static var MqttIsConnection : Bool = false
    weak var delegate: LoginWithMqttDelegate?

    var mqtt: CocoaMQTT?
    var mqttConnectionEstablished: ((Bool) -> ())?
    
    func establishConnection() // setting the Matt
    {
         let clientID = "CocoaMQTT-\(mqttProjectName)-" + String(ProcessInfo().processIdentifier)
         mqtt = CocoaMQTT(clientID: clientID, host: mqttSSL_Host_Url, port: mqttSSL_Port_Number)
         mqtt!.username = mqttUsername
         mqtt!.password = mqttPassword
         mqtt!.willMessage = CocoaMQTTWill(topic: "1", message: "dieout")
         mqtt!.keepAlive = 60
         mqtt!.delegate = self
         mqtt?.enableSSL = false
         mqtt?.autoReconnect = true
         mqtt?.autoReconnectTimeInterval = 60
         mqtt?.backgroundOnSocket = true
        
        if let arrOfRooms1 = DBManager.getRoomIdAll()  {
            print("arrOfRooms== \(String(describing: arrOfRooms))")
            arrOfRooms = arrOfRooms1
        }
        
     
        // mqtt?.subscribe(mqttChannelRetriveSubcribe, qos: CocoaMQTTQOS.qos1)
        
         let clientCertArray = getClientCertFromP12File(certName: "sslCert", certPassword: "jiniguru#123")

         var sslSettings: [String: NSObject] = [:]
         sslSettings[kCFStreamSSLCertificates as String] = clientCertArray

         mqtt!.sslSettings = sslSettings

       // ez.runThisAfterDelay(seconds: 1) {
            self.mqtt?.connect()
      //  }
        MQTTChat.MqttIsConnection = true
       
    }
    
    //MARK:- get Client Cert From P12 File
    func getClientCertFromP12File(certName: String, certPassword: String) -> CFArray? {
        // get p12 file path
        let resourcePath = Bundle.main.path(forResource: certName, ofType: "p12")
        
        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file: \(certName).p12")
            return nil
        }
        
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                print("Failed to open the certificate file: \(certName).p12")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        
        return certArray
    }
    
    
    // MARK: - send Message To User
    
    func sendMessageToUser(stringMessage : String)
    {
        
        if mqtt?.connState == .connected {
            print("mqtt?.connState")
           mqtt!.publish( mqttChannelName, withString: stringMessage, qos: .qos1)
        }

    }
    
    func checkMqttConnectionEstablishe(connectionComplitionHandler :  mqttConnectionCheckEstablished)
    {
        self.mqttConnectionEstablished = connectionComplitionHandler
        self.establishConnection()
    }
    
}
// MARK: - Custom Send Message methods
extension MQTTChat
{
    func getTelematicsDataFrom(car_id : String ,car_engine_state : String ,data_id : String ,latitude : String ,longitude: String,captured_at : String ,dongle_req_filter : String,dongle_res_raw_response : String,dongle_res_single_response : String ,dongle_res_parsed_response : String,dongle_data_type: String ,dongle_data_value : String ,session_id : String ,dongle_connection_type : String , dongle_id : String , dongle_type : String , is_telematic_on : Int)
    {
        let dictTelematic : [String : Any] = [ "project": mqttProjectName,
                                               "car_rotation": "0"]
    
        print("log Mqtt send Request",dictTelematic)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictTelematic, options: [])
        let jsonString : String = String(data: jsonData!, encoding: .utf8) ?? ""
     
        if !jsonString.isEmpty
        {
            // MQTTChat.sharedInstance.delegate = self
            self.sendMessageToUser(stringMessage: jsonString)
        }

    }
}

// MARK: - SignInDelegate methods
extension MQTTChat: CocoaMQTTDelegate {
    
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        self.delegate?.didGetCurrentState(strMessage:"trust: \(trust)" )
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        
        if ack == .accept {
            //mqtt.subscribe("EVHelper.userID" + mqttChannelRetriveSubcribe, qos: CocoaMQTTQOS.qos1)
            mqtt.subscribe(mqttChannelRetriveSubcribe, qos: CocoaMQTTQOS.qos1)
        }

//        for i in 0..<arrOfRooms.count{
//            let mqttChannelRetriveSubcribe = arrOfRooms[i]["room_id"] as! String
//            if ack == .accept {
//                //mqtt.subscribe("EVHelper.userID" + mqttChannelRetriveSubcribe, qos: CocoaMQTTQOS.qos1)
//                mqtt.subscribe(mqttChannelRetriveSubcribe, qos: CocoaMQTTQOS.qos1)
//            }
//        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
        
        self.delegate?.didGetCurrentState(strMessage:"new state: \(state)" )
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("didPublishMessage message: \(message.string.description), id: \(id)")
         self.delegate?.didGetCurrentState(strMessage:"PublishMessage: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("didReceiveMessage message : \(message.string.description), id: \(id)")
        
        let jsonString = message.string ?? ""
        let jsonData = jsonString.data(using: .utf8)!
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String : Any]
        print(dictionary!)
        
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifierReceiveMSG"), object: nil, userInfo : dictionary)

     //   let saveDongleDataId = dictionary?["data_id"] as! String
       // EVDBManager.shared.updateIsExportEvDongleData(data_Id: saveDongleDataId)
        
      //  self.delegate?.didSucceedToSignInFor(getEvDongleData: (dictionary)!)
//        //  let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + animal!)

    //    self.delegate?.didGetCurrentState(strMessage:"ReceiveMessage: \(id)" )
      
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        TRACE("topic: \(topic)")
  //  MQTTChat.sharedInstance.mqttChannelIsSubcribed = true
        if mqtt.connState == .connected {
            if self.mqttConnectionEstablished != nil
            {
                self.mqttConnectionEstablished! (true)
            }
        }
        self.delegate?.didFailToSignIn(strMessage: "Not Connected")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        TRACE("topic: \(topic)")
        
      // self.mqttChannelIsSubcribed = false
        
        if self.mqttConnectionEstablished != nil
        {
            self.mqttConnectionEstablished! (false)
        }
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
        if self.mqttConnectionEstablished != nil
        {
            self.mqttConnectionEstablished! (false)
        }
        
    }

    
}
// MARK: Utilites
extension MQTTChat {
    
    func messageRecivedDataConvert(_ data : Data) -> NSDictionary
    {
        var dictData = NSDictionary()
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
            dictData = json! as NSDictionary
        } catch {
            print("Something went wrong")
            
        }
        return dictData
    }
    
    func messageSendDataConvert(_ dictData : NSDictionary) -> Data
    {
        var data : Data!
        
        do {
            let json = try JSONSerialization.data(withJSONObject: dictData, options: [])
            data = json
        } catch {
            print(error)
        }
        return data
    }
    
    // MARK: - Utilities clientID
    
    func clientID() -> String {
        
        let userDefaults = UserDefaults.standard
        let clientIDPersistenceKey = "clientID"
        let clientID: String
        
        if let savedClientID = userDefaults.object(forKey: clientIDPersistenceKey) as? String {
            clientID = savedClientID
        } else {
            clientID = randomStringWithLength(5)
            userDefaults.set(clientID, forKey: clientIDPersistenceKey)
            userDefaults.synchronize()
        }
        
        return clientID
    }
    
    // http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    func randomStringWithLength(_ len: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        var randomString = String()
        for _ in 0..<len {
            let length = UInt32(letters.count)
            let rand = arc4random_uniform(length)
            randomString += String(letters[Int(rand)])
        }
        return String(randomString)
    }
}
extension MQTTChat {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }
        
        print("[TRACE] [\(prettyName)]: \(message)")
    }
}
 //MARK:- MQTT Offline message
extension MQTTChat
{
    func sendDongleDataToMqtt()
    {
        
        self.sendMessageToUser(stringMessage: "message")

//        guard EVHelper.userLoggedIn.status else
//        {return}

  //      let saveDongleDataArray = EVDBManager.sharedInstance().getEvDongelDeviceData()

//        if saveDongleDataArray.count > 0
//        {
//            self.checkMqttConnectionEstablishe { (success) in
//
//                if success
//                {
//                    for saveDongleData in saveDongleDataArray
//                    {
//                        if self.mqtt?.connState == .connected
//                        {
//                            self.getTelematicsDataFrom(car_id: saveDongleData.car_id ?? "", car_engine_state: saveDongleData.car_engine_state ?? "0", data_id: saveDongleData.data_id ?? "", latitude: saveDongleData.latitude ?? "0", longitude: saveDongleData.longitude ?? "0", captured_at: Date().GetUTCDate(), dongle_req_filter: saveDongleData.dongle_req_filter ?? "", dongle_res_raw_response: saveDongleData.dongle_raw_response ?? "", dongle_res_single_response: saveDongleData.dongle_single_response ?? "", dongle_res_parsed_response: saveDongleData.dongle_parsed_response ?? "", dongle_data_type: saveDongleData.dongle_type ?? "", dongle_data_value: saveDongleData.dongle_data_value ?? "", session_id: saveDongleData.session_id ?? "", dongle_connection_type:saveDongleData.dongle_connection_type ?? ""  , dongle_id: saveDongleData.dongle_id ?? "" ,dongle_type: saveDongleData.dongle_type ?? "" , is_telematic_on : saveDongleData.is_telematics ?? 0)
//                        }
//                    }
//                }
//            }
//        }
    }
}

extension Optional {
    // Unwarp optional value for printing log only
    var description: String {
        if let warped = self {
            return "\(warped)"
        }
        return ""
    }
}

//
//  ChatMessageVC.swift
//  thecareportal
//
//  Created by Jayesh on 24/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import RealmSwift
import SlackTextViewController
import SimpleImageViewer
//import IQKeyboardManagerSwift
import RxSwift
import RxGRDB
import GRDB
import Reachability

var dbPool: DatabasePool!
extension UIImage
{
    func setImageByName(imageName : String) -> UIImage
    {
        let myBundle = Bundle.init(identifier: "com.jiniguru.MQTTSDK")
        let imagePath = (myBundle?.path(forResource: "images", ofType: "bundle"))! + "/" + imageName
        let theImage = UIImage(contentsOfFile: imagePath)
        return theImage!
    }
}



let kAuthorizationToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0YjVmNzNlMC03ODFiLWRjNmMtOWZiNi01YjlhMTQ3YmI1YmIiLCJpc3MiOiJodHRwOi8vY2FyZXJzLW9ubGluZS50cmFuc2FjdGlvbi5wYXJ0bmVycy9hcGkvdjEvbG9naW4iLCJpYXQiOjE1NTI0NTE1MjMsImV4cCI6MTU1MjQ1NTEyMywibmJmIjoxNTUyNDUxNTIzLCJqdGkiOiJoNHY3U3VLOVVjQVlxYTRFIn0.hJLVlnLNYl70T00stUMt_np_rsrfDpmffbqcn6ZgEWI"

let kCell_XGap = UtilityClass.getScreenWidth(20)
let kCell_Width = UtilityClass.getScreenWidth(200)
let kCell_DateHight = 20
let kCell_SpaceOfBothSide = UtilityClass.getScreenWidth(40)
let kCell_Ygap = 5
let kCell_NameHeight = 38
let data = [["0,0", "0,1", "0,2"], ["1,0", "1,1", "1,2"]]


// swiftlint:disable file_length type_body_length
public class ChatMessageVC: SLKTextViewController
{
    @IBOutlet weak var viewNoDataFound: UIView!
    
    @IBOutlet weak var lblNoLabel: UILabel!

    var documentController: UIDocumentInteractionController?
    
    //   var replyView: ReplyView!
    var replyString: String = ""
    
    //var dataController = ChatDataController()
    var searchResult: [String: Any] = [:]
    
    var closeSidebarAfterSubscriptionUpdate = false
    
    var isRequestingHistory = false
    var isAppendingMessages = false
    
    var subscriptionToken: NotificationToken?
    var strRoomId : String?{
        didSet{
            subscribeToSelectedRoom()
        }
    }
    var subscription: Subscription? {
        didSet {
            subscriptionToken?.invalidate()
            
            guard
                let subscription = subscription,
                !subscription.isInvalidated
                else {
                    return
            }
            if let oldValue = oldValue, oldValue.identifier != subscription.identifier {
                //                unsubscribe(for: oldValue)
            }
            textView.text = DraftMessageManager.draftMessage(for: subscription)
        }
    }
    
    //======== new =======
    
    private var workItem: DispatchWorkItem?
    
    var popup:UIView!
    var myView:UIView!
   // var myCustomView : CustomTypingView!
    var picker:UIImagePickerController? = UIImagePickerController()
    
    var arrayDisplayController =  [[String: Any]]()
    var arrayTypingDisplay =  [[String: Any]]()
    
    var controller: FetchedRecordsController<chatDataModal>!

    let netWorkReachability = Reachability()!
    
    var dataChatArray = NSMutableArray()
    var isSender : Bool = false
    
    override public var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    override public class func tableViewStyle(for decoder: NSCoder) -> UITableView.Style {
        
        return .plain
    }

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        //    self.tempDBQuery()
        
        NetworkManager.isReachable { _ in
            self.loadAPIAndOtherData()
        }
        
        //=======================================================================================

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let databasePath = documentsPath.appendingPathComponent("db.sqlite")
        do {
            dbPool = try AppDatabase.openDatabase(atPath: databasePath)
        } catch {
            //handle error
            print(error)
        }
        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/#memory-management
        dbPool.setupMemoryManagement(in: UIApplication.shared)
        
        //=======================================================================================
        self.registerCells()
        print("viewDidLoad")
        
        picker?.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        self.setUpTheBottomMessageTextView()
        self.tableView.separatorStyle = .none
        
       self.realTimeDataFetch()

        NetworkManager.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.NotificationIdentifierReceiveMSG(notification:)), name: Notification.Name("NotificationIdentifierReceiveMSG"), object: nil)
        
    }
    
    @objc func NotificationIdentifierReceiveMSG(notification: Notification) {
        
        print("notification.userInfo \(String(describing: notification.userInfo as? [String : Any]))")
        
        if notification.userInfo != nil {
            
            let dictMassage : NSDictionary = notification.userInfo as? [String : Any] as! NSDictionary
            
            if dictMassage.object(forKey: "message_id") != nil {
                
                arrayTypingDisplay.removeAll()
                
                let strMessage_id : String = dictMassage.object(forKey: "message_id") as! String
                
                try! dbPool.read { db in
                    
                    print("READ:")
                    if let row = try Row.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                        
                        let dict : NSDictionary = Dictionary(
                            row.map { (column, dbValue) in
                                (column, dbValue.storage.value as AnyObject)
                            },
                            uniquingKeysWith: { (_, right) in right }) as NSDictionary
                        print(dict)
                        
                        try dbPool.write { db in
                            if var chatUpdate = try chatDataModal.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                                chatUpdate.is_export = "1"
                                try chatUpdate.update(db)
                            }
                        }
                    }else
                    {
                        try! dbPool.write { db in
                            print("write:")
                            var chatModal = chatDataModal(id: nil, message_id: dictMassage.object(forKey: "message_id") as! String, message_type: dictMassage.object(forKey: "message_type") as! String, message: dictMassage.object(forKey: "message") as! String, full_name: dictMassage.object(forKey: "full_name") as! String, action: dictMassage.object(forKey: "action") as! String, type: dictMassage.object(forKey: "type") as! String, project: dictMassage.object(forKey: "project") as! String, original_file_name: "1", room_id: dictMassage.object(forKey: "room_id") as! String, profile_picture_url: dictMassage.object(forKey: "profile_picture_url") as! String, email: dictMassage.object(forKey: "email") as! String, login_user_id: dictMassage.object(forKey: "login_user_id") as! String, created_at: dictMassage.object(forKey: "created_at") as! String , is_export : "1",message_date : dictMassage.object(forKey: "created_at") as! String)
                            
                            try! chatModal.insert(db)
                        }
                     //   self.tempDBQuery(roomId: self.strRoomId)
                     //  self.realTimeDataFetch()
                    }
                }
            }
            else
            {
                if  dictMassage.object(forKey: "login_user_id") as! String !=  kLoginUserId &&  (dictMassage.object(forKey: "room_id") as! String) == self.strRoomId
                {
                    let dictMessageTyping  = NSMutableDictionary()
                    if dictMassage.object(forKey: "typing_display_timer") as! Int != 0{
                        dictMessageTyping.setValue( dictMassage.object(forKey: "action") as! String, forKey:"action" )
                        dictMessageTyping.setValue( dictMassage.object(forKey: "typing_display_timer") as! Int, forKey:"typing_display_timer" )
                        //  dictMessageTyping.setValue(20, forKey:"typing_display_timer" )
                        dictMessageTyping.setValue( dictMassage.object(forKey: "full_name") as! String, forKey:"full_name" )
                        dictMessageTyping.setValue( dictMassage.object(forKey: "login_user_id") as! String, forKey:"login_user_id" )
                        dictMessageTyping.setValue( dictMassage.object(forKey: "profile_picture_url") as! String, forKey:"profile_picture_url" )
                        
                        arrayTypingDisplay.append(dictMessageTyping as! [String : Any])
                        
                        //                    if arrayTypingDisplay.count == 0
                        //                    {
                        //                        arrayTypingDisplay.append(dictMessageTyping as! [String : Any])
                        //                    }
                        //                    else{
                        //                        for i in 0..<arrayTypingDisplay.count{
                        //                            let str = dictMassage.object(forKey: "login_user_id") as? String
                        //                            if str == arrayTypingDisplay[i]["login_user_id"] as? String
                        //                            {
                        //                                arrayTypingDisplay.remove(at: i)
                        //                                arrayTypingDisplay.append(dictMessageTyping as! [String : Any])
                        //                                //  break
                        //                            }
                        //                            else
                        //                            {
                        //                                arrayTypingDisplay.append(dictMessageTyping as! [String : Any])
                        //                                break
                        //                            }
                        
                        //                            print("for loop arrayTypingDisplay.count \(arrayTypingDisplay.count)")
                        //
                        //                        }
                        //                    }
                        
                        
                   //     print("Last dictMessageTyping Last: \(arrayTypingDisplay)")
                        
                        //==========
                        for i in 0..<arrayTypingDisplay.count{
                            if arrayTypingDisplay.count > 1{
                                print("==== arrayTypingDisplay arrayTypingDisplay.count \(arrayTypingDisplay.count)")
                                
                                print("loopp arrayTypingDisplay.count ==  \(arrayTypingDisplay)")
                                let str = dictMassage.object(forKey: "login_user_id") as? String
                                if str == arrayTypingDisplay[i]["login_user_id"] as? String
                                {
                                    //arrayTypingDisplay.remove(at: i)
                                    print("same")
                                    // Get unique data
                                    let set = NSSet(array: arrayTypingDisplay)
                                    print(set.allObjects)
                                    arrayTypingDisplay = (set.allObjects as? [[String: Any]])!
                                    print("stop")
                                    
                                    workItem?.cancel()
                                    break
                                }
                            }
                            arrayTypingDisplay.reverse()
                        }
                       // print("Last dictMessageTyping Last: \(arrayTypingDisplay)")
                       // print("notification count arrayDisplayController== \(self.arrayDisplayController.count)")
                        
                        self.tableView.reloadData()
//                        let screenSize: CGRect = UIScreen.main.bounds
//                        myCustomView =  Bundle.main.loadNibNamed("CustomTypingView", owner: self, options: nil)!.first as? CustomTypingView
//
//                        var testRect: CGRect = myCustomView!.frame
//                        testRect.size.height = 70
//                        testRect.origin.y =  screenSize.height - 270
//                        myCustomView!.frame = testRect
//                        myCustomView.isHidden = false
                        
                        //  var newFrame: CGRect  = self.tableView.tableHeaderView!.frame
                        //  newFrame.size.height = newFrame.size.height + 100
                        //  self.tableView.tableHeaderView!.frame = testRect
//                        self.tableView.tableHeaderView = myCustomView
//                        self.tableView.tableHeaderView?.transform = self.tableView.transform
//                        self.typingView()
                        
                    }
                }
            }
            self.tableView.reloadData()

        }
    }
    //    fileprivate func shodHideNoDataFoundView(isHide : Bool){
    //
    //        self.tableView.backgroundView = viewNoDataFound
    //
    //        self.viewNoDataFound.isHidden = isHide
    //    }

    public func tempDBQuery(roomId : String?)
    {
        print("====tempDBQuery roomId \(String(describing: roomId))====")
        if roomId != ""
        {
            arrayDisplayController.removeAll()
            try! dbPool.read { db in
                print("====fetchAllData====")
                
                let fetchAllData = try chatDataModal.fetchAll(db, "select message_date,is_export,email,profile_picture_url, room_id, original_file_name,project,type,action,message_id, message, created_at, login_user_id, message_type, full_name, avatar, (case when priority != null OR priority != '' then priority else 0 end) as pinnedPriority from (select hcm.message_id as message_id, hcm.action as action, hcm.type as type,hcm.original_file_name as original_file_name, hcm.room_id as room_id,hcm.profile_picture_url as profile_picture_url, hcm.email as email, hcm.is_export as is_export, hcm.message_date as message_date, hcm.project as project,  message as message, hcm.created_at as created_at,hcm.login_user_id as login_user_id,message_type as message_type, hc_user_profile.full_name as full_name, profile_picture as avatar, (select priority_flag  from hc_chat_messages_priorities where message_id = hcm.message_id) as priority from chatDataModal as hcm, hc_user_profile where hcm.room_id = '\(roomId ?? "")' and hc_user_profile.user_id = hcm.login_user_id order by hcm.created_at desc)")
                
                //   print("fetch fetchAllData == \(fetchAllData)")
                
                   let count = try! chatDataModal.fetchCount(db)
                
                //    print("fetch count == \(count)")
                if count > 0
                {
                    for item in fetchAllData
                    {
                        let chatData = item
                        
                        //   if chatData.message_type  == "text"
                        // {
                        
                        let dict : NSDictionary = Dictionary(
                            chatData.databaseDictionary.map { (column, dbValue) in
                                (column, dbValue.storage.value as AnyObject)
                            },
                            uniquingKeysWith: { (_, right) in right }) as NSDictionary
                        
                        arrayDisplayController.append(dict as! [String : Any])
                        //    print(arrayDisplayController)
                        
                        //}
                    }
                    
                }
              //  self.tableView.reloadData()
             
            }
        }
    }
    func loadAPIAndOtherData()
    {
        print("loadAPIAndOtherData")

        //======
//        MQTTChat.sharedInstance.checkMqttConnectionEstablishe { (success) in
//            if success
//            {
//             //   self.offlineMessageSend()
//            }
//        }
        //======
        
                if MQTTChat.sharedInstance.mqtt?.connState != .connected
                {
                    MQTTChat.sharedInstance.establishConnection()
                //    self.offlineMessageSend()
                }
        
        //       self.MqttConnectioCheck()
        //        if MQTTChat.sharedInstance.mqtt?.connState != .connected
        //        {
        //            MQTTChat.sharedInstance.establishConnection()
        //        }
        
        //        try! dbPool.read { db in
        //            //chatDataModal.order(Column("created_at").desc)
        //            let request = chatDataModal.filter(Column("is_export") == "1")
        //            let AllChat = try! request.fetchAll(db)
        //            let chatLastData = AllChat.last
        //            // print(AllChat)
        //            if chatLastData?.created_at != nil{
        //                self.ReceiverDataFetchAPIManager((chatLastData?.created_at)!)
        //            }
        //        }
        
    }
    
    override public func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
    }
    override public func viewWillAppear(_ animated: Bool) {
        
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
        //        if MQTTChat.MqttIsConnection == true
        //        {
        //            // self.offlineMessageSend()
        //        }
//        if MQTTChat.sharedInstance.mqtt?.connState != .connected
//        {
//            MQTTChat.sharedInstance.establishConnection()
//        }
        
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    // MARK: setUpTheBottomMessageTextView
    func setUpTheBottomMessageTextView()
    {
        self.bounces = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.isInverted = true
        
        view.bringSubviewToFront(textInputbar)
        view.bringSubviewToFront(leftButton)
        
        leftButton.isHidden = false
        
        let imageupload = UIImage().setImageByName(imageName: "img_upload")
        print("imageupload== \(imageupload)")

        self.leftButton.setImage(imageupload, for: .normal)
        self.leftButton.tintColor = UIColor.darkGray
        self.textInputbar.rightButton.setTitle("", for: .normal)
        let imagesend = UIImage().setImageByName(imageName: "sendbtn")
        print("imagesend== \(imagesend)")
        self.textInputbar.rightButton.setImage(imagesend, for: .normal)
        self.textInputbar.autoHideRightButton = false
        
        self.textInputbar.editorTitle.textColor = UIColor.lightGray
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        self.registerPrefixes(forAutoCompletion: ["@",  "#", ":", "+:", "/"])
        
        self.textView.placeholder = "Message";
        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
    }
    
    // MARK: Register Cells
    fileprivate func registerCells() {
        
        let bundleMessageSender = Bundle(for: MessageSenderCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "MessageSenderCell",
            bundle: bundleMessageSender
        ), forCellReuseIdentifier: "MessageSenderCell")
        
        let bundleMessageReceiver = Bundle(for: MessageReceiverCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "MessageReceiverCell",
            bundle: bundleMessageReceiver
        ), forCellReuseIdentifier:"MessageReceiverCell")
        
        let bundleReceiverImage = Bundle(for: ReceiverImageCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "ReceiverImageCell",
            bundle: bundleReceiverImage
        ), forCellReuseIdentifier:"ReceiverImageCell")
        
        let bundleSenderImage = Bundle(for: SenderImageCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "SenderImageCell",
            bundle: bundleSenderImage
        ), forCellReuseIdentifier:"SenderImageCell")
        
        let bundleViewNoDataFound = Bundle(for: ViewNoDataFoundCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "ViewNoDataFoundCell",
            bundle: bundleViewNoDataFound
        ), forCellReuseIdentifier:"ViewNoDataFoundCell")
        
//        self.tableView.register(UINib(
//            nibName: "TypingCell",
//            bundle: Bundle.main
//        ), forCellReuseIdentifier:"TypingCell")

        let bundletwoTyping = Bundle(for: twoTypingCell.classForCoder())
        self.tableView.register(UINib(
            nibName: "twoTypingCell",
            bundle: bundletwoTyping
        ), forCellReuseIdentifier:"twoTypingCell")
        
        let bundleTyping = Bundle(for: TypingCell.classForCoder())

        self.tableView.register(UINib.init(nibName: "TypingCell", bundle: bundleTyping), forHeaderFooterViewReuseIdentifier: "TypingCell")
    }
    // MARK: Table Delegate
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return data.count
//
//    }
    
    // number of rows in table view
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        print(controller.sections[section].numberOfRecords)

        if controller != nil
        {
            return controller.sections[section].numberOfRecords
        }
        else{
            return 0
        }
//        print(" numberOfRowsInSection count arrayDisplayController== \(self.arrayDisplayController.count)")
//        if( arrayDisplayController.count > 0)
//        {
//            return arrayDisplayController.count
//        }
//        else
//        {
//            return 0
//        }
    }
    @objc func dismissAlert(){
        if popup != nil { // Dismiss the view from here
            popup.removeFromSuperview()
        }
    }
    func showAlert() {
        // customise your view
        popup = UIView(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
        popup.backgroundColor = UIColor.red
        
        // show on screen
        self.view.addSubview(popup)
        
        // set the timer
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    func setTimer(timer : Int?)
    {
        sleep(3)
        
    }
    
//    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TypingCell") as! TypingCell
//        //   let cell: TypingCell! = tableView.dequeueReusableCell(withIdentifier: "TypingCell") as? TypingCell
//        cell.transform = self.tableView.transform
//
//        print("viewForFooterInSection arrayTypingDisplay.count ==  \(arrayTypingDisplay)")
//        var strNameTyping = ""
//        //: NSMutableString = NSMutableString()
//        //        if( arrayTypingDisplay.count > 0)
//        //        {
//        cell.btnImage.isHidden = false
//        cell.imageViewThumb.isHidden = false
//        for i in 0..<arrayTypingDisplay.count{
//
//            let str = arrayTypingDisplay[i]["full_name"] as? String
//            let strTimer = arrayTypingDisplay[i]["typing_display_timer"] as? Int
//            strNameTyping = str! + " is typing...."
//            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + DispatchTimeInterval.seconds(strTimer!))) {
//                print("strTimer")
//                DispatchQueue.main.async {
//                    print("main async")
//                    print(" 1,3 arrayTypingDisplay.count ==  \(self.arrayTypingDisplay.count)")
//
//                    if( self.arrayTypingDisplay.count > 0 && self.arrayTypingDisplay.count > i )
//                    {
//                        self.arrayTypingDisplay.remove(at: i)
//                    }
//                    self.tableView.reloadData()
//                }
//            }
//
//            let dictMessage  = NSMutableDictionary()
//            dictMessage.setValue(arrayTypingDisplay[i]["full_name"] as! String, forKey:kName)
//
//            if(arrayTypingDisplay.count == 1){
//                dictMessage.setValue(arrayTypingDisplay[i]["profile_picture_url"] as! String, forKey:kprofile_picture_url)
//                cell.lblName.text =  strNameTyping as String
//
//                cell.configureCell(dictData: dictMessage, countArray: 1)
//            }
//            else if(arrayTypingDisplay.count == 2){
//
//                print("3 arrayTypingDisplay.count ==  \(self.arrayTypingDisplay.count)")
//                print("i 3 arrayTypingDisplay.count ==  \(i)")
//
//                dictMessage.setValue(arrayTypingDisplay[0]["profile_picture_url"] as! String, forKey:kprofile_picture_url)
//                dictMessage.setValue(arrayTypingDisplay[1]["profile_picture_url"] as! String, forKey:"profile_picture_url_2")
//
//                cell.lblName.text =  String(arrayTypingDisplay[0]["full_name"] as! String) + " " + String(arrayTypingDisplay[1]["full_name"] as! String) + " is typing...."
//
//                cell.configureCell(dictData: dictMessage, countArray: 2)
//
//            }
//            else if(arrayTypingDisplay.count == 3){
//
//                print("3 arrayTypingDisplay.count ==  \(self.arrayTypingDisplay.count)")
//                print("i 3 arrayTypingDisplay.count ==  \(i)")
//
//                dictMessage.setValue(arrayTypingDisplay[0]["profile_picture_url"] as! String, forKey:kprofile_picture_url)
//                dictMessage.setValue(arrayTypingDisplay[1]["profile_picture_url"] as! String, forKey:"profile_picture_url_2")
//                dictMessage.setValue(arrayTypingDisplay[2]["profile_picture_url"] as! String, forKey:"profile_picture_url_3")
//                cell.configureCell(dictData: dictMessage, countArray: 3)
//                cell.lblName.text =  String(arrayTypingDisplay[0]["full_name"] as! String) + " and other"  + " is typing...."
//            }
//            else if(arrayTypingDisplay.count == 4){
//
//                print("3 arrayTypingDisplay.count ==  \(self.arrayTypingDisplay.count)")
//                print("i 3 arrayTypingDisplay.count ==  \(i)")
//
//                dictMessage.setValue(arrayTypingDisplay[0]["profile_picture_url"] as! String, forKey:kprofile_picture_url)
//                dictMessage.setValue(arrayTypingDisplay[1]["profile_picture_url"] as! String, forKey:"profile_picture_url_2")
//                dictMessage.setValue(arrayTypingDisplay[2]["profile_picture_url"] as! String, forKey:"profile_picture_url_3")
//                dictMessage.setValue(arrayTypingDisplay[3]["profile_picture_url"] as! String, forKey:"profile_picture_url_4")
//
//                cell.configureCell(dictData: dictMessage, countArray: 4)
//                cell.lblName.text =  String(arrayTypingDisplay[0]["full_name"] as! String) + " and other"  + " is typing...."
//            }
//            else if(arrayTypingDisplay.count == 5){
//
//                print("3 arrayTypingDisplay.count ==  \(self.arrayTypingDisplay.count)")
//                print("i 3 arrayTypingDisplay.count ==  \(i)")
//
//                dictMessage.setValue(arrayTypingDisplay[0]["profile_picture_url"] as! String, forKey:kprofile_picture_url)
//                dictMessage.setValue(arrayTypingDisplay[1]["profile_picture_url"] as! String, forKey:"profile_picture_url_2")
//                dictMessage.setValue(arrayTypingDisplay[2]["profile_picture_url"] as! String, forKey:"profile_picture_url_3")
//                dictMessage.setValue(arrayTypingDisplay[3]["profile_picture_url"] as! String, forKey:"profile_picture_url_4")
//                dictMessage.setValue(arrayTypingDisplay[4]["profile_picture_url"] as! String, forKey:"profile_picture_url_5")
//
//                cell.configureCell(dictData: dictMessage, countArray: 5)
//                cell.lblName.text =  String(arrayTypingDisplay[0]["full_name"] as! String) + " and other"  + " is typing...."
//            }
//        }
//        print("strNameTyping : \(strNameTyping)")
//
//        return cell
//
//    }
//    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        if( arrayTypingDisplay.count > 0)
//        {
//            return 60
//        }
//        else{
//            return 0
//        }
//    }
    
    
    // create a cell for each table view row
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chatData = controller.record(at: indexPath)
        print("cell data")
        print("chatData.message== \(chatData.message)")

        print("chatData ------== \(chatData)")

        if chatData.login_user_id != kLoginUserId
        {
            if chatData.message_type == "text"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageReceiverCell", for: indexPath)
                    as! MessageReceiverCell

                let dictMessage  = NSMutableDictionary()
                dictMessage.setValue(chatData.message, forKey:kMessage )
                dictMessage.setValue(chatData.created_at, forKey:kDate )
                dictMessage.setValue(chatData.full_name, forKey:kName)
                dictMessage.setValue("", forKey:kprofile_picture_url)
                print("dictMessage == \(dictMessage)")
                
                cell.configureCell(dictData: dictMessage)
                
                cell.transform = self.tableView.transform
                cell.selectionStyle = .none
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath)
                    as! ReceiverImageCell
                print("chatData.profile_picture_url== \(chatData.profile_picture_url)")

                
//                if strprofile_picture_url == nil
//                {
//                    strprofile_picture_url = ""
//                }
//                else{
//                    strprofile_picture_url = "http://carers-online.transaction.partners/uploads/carers-online/profile_image/" + strprofile_picture_url!
//                }
                
                let dictMessage  = NSMutableDictionary()
                dictMessage.setValue(chatData.message, forKey:kMessage )
                dictMessage.setValue(chatData.created_at, forKey:kDate )
                dictMessage.setValue(chatData.full_name, forKey:kName)

             //   dictMessage.setValue(strprofile_picture_url, forKey:kprofile_picture_url)

                cell.configureCell(dictData: dictMessage)
                
                cell.transform = self.tableView.transform
                cell.selectionStyle = .none
                return cell
            }
            
            
        }
        else
        {
            if chatData.message_type == "text"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSenderCell", for: indexPath)
                    as! MessageSenderCell
                
                let dictMessage  = NSMutableDictionary()
                dictMessage.setValue(chatData.message, forKey:kMessage )
                dictMessage.setValue(chatData.created_at, forKey:kDate )
                
                dictMessage.setValue("Rajvi Turakhia", forKey:kName)
                dictMessage.setValue("", forKey:kprofile_picture_url)
                cell.configureCell(dictData: dictMessage)
                
                cell.transform = self.tableView.transform
                cell.selectionStyle = .none
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath)
                    as! SenderImageCell
                
                let dictMessage  = NSMutableDictionary()
                dictMessage.setValue(chatData.message, forKey:kMessage )
                dictMessage.setValue(chatData.created_at, forKey:kDate )
                dictMessage.setValue(chatData.is_export, forKey: "is_export")
                
                cell.configureCell(dictData: dictMessage)
                
                cell.transform = self.tableView.transform
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    // method to run when table view cell is tapped
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == self.tableView
        {
            
            let chatData = controller.record(at: indexPath)
            
            if chatData.message_type == "text"
            {
                
                let labelSize = UtilityClass.rectForText(text: (chatData.message), font:defaultFont, maxSize: CGSize(width: Int(kCell_Width), height: 9999))
                
                var height = labelSize.height
                height += 20
                height += 20
                height += 5
                return height
            }
            else
            {
                return 220
            }
        }
        else
        {
            return 0
        }
    }
    
    
    // MARK: Imange Picker
    @objc func ImagePickerClicked()
    {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker!.sourceType = UIImagePickerController.SourceType.camera
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    func openGallary()
    {
        picker!.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker!, animated: true, completion: nil)
    }
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
//        view.addGestureRecognizer(tapGesture)
//    }
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SLKTextViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
    
}
extension Array
{
    func toDictionary<H:Hashable, T>(byTransforming transformer: (Element) -> (H, T)) -> Dictionary<H, T>
    {
        var result = Dictionary<H,T>()
        self.forEach({ element in
            let (key,value) = transformer(element)
            result[key] = value
        })
        return result
    }
}
// MARK: Reachability Delegate
extension ChatMessageVC : ReachabilityDelegate
{
    func reachabilityStatusChangeHandler(_ reachability: Reachability) {
        
        print("reachabilityStatusChangeHandler")
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            self.loadAPIAndOtherData()
        case .cellular:
            print("Reachable via Cellular")
            self.loadAPIAndOtherData()
        case .none:
            print("Network not reachable")
        }
    }
}
// MARK: SlackTextViewController
extension ChatMessageVC
{
    
    override public func canPressRightButton() -> Bool {
        return true
    }
    
    override public func didPressRightButton(_ sender: Any?) {
        sendMessage()
    }
    
    override public func didPressLeftButton(_ sender: Any?) {
        //buttonUploadDidPressed()
        self.ImagePickerClicked()
    }
    
    override public func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        sendMessage()
    }
    
    override public func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    override public func textViewDidChange(_ textView: UITextView) {
        
    }
    
    override public func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        
        sendMessage()
        
    }
}
// MARK: sendMessage
extension ChatMessageVC {
    
    fileprivate func sendMessage() {
        
        guard let messageText = textView.text, messageText.count > 0 else { return }
        
        rightButton.isEnabled = false
        
        if !messageText.isEmpty {
            
            textView.text = ""
            rightButton.isEnabled = true
            
            let createdDate = self.convertToString(date: Date())
            
            let dictData  = NSMutableDictionary()
            dictData.setValue(messageText, forKey:kMessage)
            dictData.setValue("09:23", forKey:kDate )
            
            self.textView.refreshFirstResponder()
            
            if isSender
            {
                isSender = false
            }else
            {
                isSender = true
            }
            
            let messageId = String.random(36)
            
            
            try! dbPool.write { db in
                
                var chatModal = chatDataModal(id: nil, message_id: messageId, message_type: "text", message: messageText, full_name: "Rajvi Turakhia", action: "message", type: "store", project: "HOMECARE", original_file_name: "1", room_id: ChannelName, profile_picture_url: "ashwinbhai.png", email: "rajvi.turakhia@jini.guru", login_user_id: "1", created_at: createdDate, is_export : "0",message_date : createdDate)
                
                try! chatModal.insert(db)
            }
            try! dbPool.read { db in
                
                let chatArray = NSMutableArray()
                
                let request = chatDataModal.filter(Column("is_export") == "0")
                let count = try! request.fetchCount(db)
                let AllChat = try! request.fetchAll(db)
                
                if count > 0
                {
                    for item in AllChat
                    {
                        let chatData = item
                        if chatData.message_type  == "text"
                        {
                            let dict : NSDictionary = Dictionary(
                                chatData.databaseDictionary.map { (column, dbValue) in
                                    (column, dbValue.storage.value as AnyObject)
                                },
                                uniquingKeysWith: { (_, right) in right }) as NSDictionary
                            chatArray.add(dict)
                            if chatArray.count == count
                            {
                                let chatLastData1 = AllChat.last
                                if chatLastData1?.created_at != nil{
                                    self.ReceiverDataFetchAPIManager((chatLastData1?.created_at)! , chatArray)
                                }
                            }
                        }
                    }
                }
                else{
                    // if chatLastData?.created_at != nil{
                    self.ReceiverDataFetchAPIManager(createdDate , chatArray)
                    //}
                }
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: MQTT Connectio Check
extension ChatMessageVC{
    
    
    //    func MqttConnectioCheck()
    //    {
    //        MQTTChat.sharedInstance.makeConnectionRequest(host_url, Int(port_number), clientID, mqttUsername, mqttPassword) { (message, error) in
    //
    //            if error != nil
    //            {
    //                print(message)
    //            }else
    //            {
    //                print(message)
    //            }
    //            if MQTTChat.MqttIsConnection
    //            {
    //                MQTTChat.sharedInstance.subscribeToChannel(){
    //                    (message, error) in
    //
    //                    if error == nil
    //                    {
    //                        print("connected successfully")
    //
    //                    }else{
    //                        print(message)
    //                    }
    //
    //                }
    //
    //            }
    //
    //        }
    //    }
}

private let chatMessageSortedBy = chatDataModal.order(Column("created_at").desc)

extension ChatMessageVC
{
    func offlineMessageSend()
    {
        try! dbPool.read { db in
            
            let request1 = chatDataModal.filter(Column("is_export") == "1")
            let AllChat1 = try! request1.fetchAll(db)
            var chatLastData = AllChat1.last
            let count1 = try! request1.fetchCount(db)
            
            let chatArray = NSMutableArray()
            
            let request = chatDataModal.filter(Column("is_export") == "0")
            let count = try! request.fetchCount(db)
            let AllChat = try! request.fetchAll(db)
            
            if count > 0
            {
                for item in AllChat
                {
                    let chatData = item
                    if chatData.message_type  == "text"
                    {
                        let dict : NSDictionary = Dictionary(
                            chatData.databaseDictionary.map { (column, dbValue) in
                                (column, dbValue.storage.value as AnyObject)
                            },
                            uniquingKeysWith: { (_, right) in right }) as NSDictionary
                        
                        chatArray.add(dict)
                        
                        if chatArray.count == count
                        {
                            let chatLastData1 = AllChat.last
                            
                            if chatLastData1?.created_at != nil{
                                self.ReceiverDataFetchAPIManager((chatLastData1?.created_at)! , chatArray)
                            }
                        }
                    }
                    else
                    {
                        self.ReceiverDataFetchAPIManager("2019-04-05 11:30:30" , chatArray)
                    }
                }
            }
            else{
                // if chatLastData?.created_at != nil{
                self.ReceiverDataFetchAPIManager("2019-04-02 11:30:30" , chatArray)
                //}
            }
            //25-3
            
            //            if count1 == 0
            //            {
            //                self.ReceiverDataFetchAPIManager("2019-04-02 11:30:30" , chatArray)
            //            }
            
            //            if count > 0
            //            {
            //
            //                for item in AllChat
            //                {
            //                    let chatData = item
            //
            //                    let dict : NSDictionary = Dictionary(
            //                        chatData.databaseDictionary.map { (column, dbValue) in
            //                            (column, dbValue.storage.value as AnyObject)
            //                        },
            //                        uniquingKeysWith: { (_, right) in right }) as NSDictionary
            //
            //                    if dict.object(forKey: "login_user_id") as! String == SharedManager.sharedInstance.userProfile.user_id! //kLoginUserId
            //                    {
            //                        let mData = self.messageSendDataConvert(dict as NSDictionary)
            //
            //                        if mData.count > 0
            //                        {
            //                            MQTTChat.sharedInstance.delegate = self
            //                            //   MQTTChat.sharedInstance.sendMessageToUser(stringMessage: "mData")
            //                            let jsonString = String(data: mData, encoding: .utf8)
            //                            MQTTChat.sharedInstance.sendMessageToUser(stringMessage: jsonString!)
            //                        }
            //                    }
            //                }
            //
            //            }
            
            //     print("Count of is Export \(count)")
        }
    }
    
    
    //    func offlineMessageSend()
    //    {
    //        try! dbPool.read { db in
    //
    //            let request1 = chatDataModal.filter(Column("is_export") == "1")
    //            let AllChat1 = try! request1.fetchAll(db)
    //            let chatLastData = AllChat1.last
    //
    //            let request = chatDataModal.filter(Column("is_export") == "0")
    //            let count = try! request.fetchCount(db)
    //            let AllChat = try! request.fetchAll(db)
    //
    //            let chatArray = NSMutableArray()
    //
    //
    //            if count > 0
    //            {
    //
    //                for item in AllChat
    //                {
    //                    let chatData = item
    //
    //                    if chatData.message_type  == "text"
    //                    {
    //
    //                        let dict : NSDictionary = Dictionary(
    //                            chatData.databaseDictionary.map { (column, dbValue) in
    //                                (column, dbValue.storage.value as AnyObject)
    //                            },
    //                            uniquingKeysWith: { (_, right) in right }) as NSDictionary
    //
    //                        chatArray.add(dict)
    //
    //                        if chatArray.count == count
    //                        {
    //                            if chatLastData?.created_at != nil{
    //                                self.ReceiverDataFetchAPIManager((chatLastData?.created_at)! , chatArray)
    //                            }
    //                        }
    //
    //                        //                    if dict.object(forKey: "login_user_id") as! String == kLoginUserId
    //                        //                    {
    //                        //                        let mData = self.messageSendDataConvert(dict as NSDictionary)
    //                        //
    //                        //                        if mData.count > 0
    //                        //                        {
    //                        //                            MQTTChat.sharedInstance.delegate = self
    //                        //                            MQTTChat.sharedInstance.sendMessageToUser(dataOfMessage: mData)
    //                        //                        }
    //                        //                    }
    //
    //                    }
    //                    else
    //                    {
    //                        //      self.uploadImageFromServer(chatData)
    //                    }
    //                }
    //
    //            }else{
    //                if chatLastData?.created_at != nil{
    //                    self.ReceiverDataFetchAPIManager((chatLastData?.created_at)! , chatArray)
    //                }
    //            }
    //
    //            print("Count of is Export \(count)")
    //        }
    //    }
}
// MARK: MQTT RxSWift
extension ChatMessageVC
{
    func realTimeDataFetch()
    {
        print("realTimeDataFetch")
        let request = chatMessageSortedBy
        do {
            controller = try FetchedRecordsController(dbPool, request: request)
            controller?.trackChanges(
                willChange: { [unowned self] _ in
                    self.tableView.beginUpdates()
                },
                onChange: { [unowned self] (controller, record, change) in
                    switch change {
                    case .insertion(let indexPath):
                        
                        if MQTTChat.MqttIsConnection == true
                        {
                            
                            let chatData = controller.record(at: indexPath)
                            
                            let dict : NSDictionary = Dictionary(
                                chatData.databaseDictionary.map { (column, dbValue) in
                                    (column, dbValue.storage.value as AnyObject)
                                },
                                uniquingKeysWith: { (_, right) in right }) as NSDictionary
                            
                            if dict.object(forKey: "login_user_id") as! String == kLoginUserId
                            {
                                
                                if chatData.message_type  == "text"
                                {
                                    let mData = self.messageSendDataConvert(dict as NSDictionary)
                                    
                                    if mData.count > 0
                                    {
                                        MQTTChat.sharedInstance.delegate = self
                                        let jsonString = String(data: mData, encoding: .utf8)
                                        MQTTChat.sharedInstance.sendMessageToUser(stringMessage: jsonString!)                                }
                                }
                                else
                                {
                                    // self.uploadImageFromServer(chatData)
                                }
                            }
                            
                        }
                        
                        self.tableView.insertRows(at: [indexPath], with: .fade)
                        
                    case .deletion(let indexPath):
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    case .update(let indexPath, _):
                        if self.tableView.cellForRow(at: indexPath) != nil {
                            
                        }
                        
                    case .move(let indexPath, let newIndexPath, _):
                        // Actually move cells around for more demo effect :-)
                        let cell = self.tableView.cellForRow(at: indexPath)
                        self.tableView.moveRow(at: indexPath, to: newIndexPath)
                        if cell != nil {
                            //   self.configure(cell, at: newIndexPath)
                        }
                    }
                },
                didChange: { [unowned self] _ in
                    self.tableView.endUpdates()
            })
            try! controller?.performFetch()
        }
        catch
        {
            print("try catch")
        }
    }
}

// MARK: MQTT Delegate

extension ChatMessageVC : LoginWithMqttDelegate
{
    func didFailToSignIn(strMessage: String) {
        print("Journey error Start View Controller ",strMessage)
        
    }
    
    func didSucceedToSignInFor(getEvDongleData: [String : Any]) {
        print("didSucceedToSignInFor == ",getEvDongleData)
        
    }
    
    func didGetCurrentState(strMessage: String) {
        print("Journey Current State Start View Controller ",strMessage)
        
    }
    
    
    
    func didSucceedToSignInFor(user: Data)
    {
        let dictMassage : NSDictionary =   self.messageRecivedDataConvert(user)
        print(dictMassage)
        if dictMassage.object(forKey: "message_id") != nil {
            
            let strMessage_id : String = dictMassage.object(forKey: "message_id") as! String
            
            try! dbPool.read { db in
                if let row = try Row.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                    
                    let dict : NSDictionary = Dictionary(
                        row.map { (column, dbValue) in
                            (column, dbValue.storage.value as AnyObject)
                        },
                        uniquingKeysWith: { (_, right) in right }) as NSDictionary
                    print(dict)
                    
                    
                    try dbPool.write { db in
                        if var chatUpdate = try chatDataModal.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                            chatUpdate.is_export = "1"
                            try chatUpdate.update(db)
                        }
                    }
                }else
                {
                    try! dbPool.write { db in
                        
                        var chatModal = chatDataModal(id: nil, message_id: dictMassage.object(forKey: "message_id") as! String, message_type: dictMassage.object(forKey: "message_type") as! String, message: dictMassage.object(forKey: "message") as! String, full_name: dictMassage.object(forKey: "full_name") as! String, action: dictMassage.object(forKey: "action") as! String, type: dictMassage.object(forKey: "type") as! String, project: dictMassage.object(forKey: "project") as! String, original_file_name: "1", room_id: dictMassage.object(forKey: "room_id") as! String, profile_picture_url: dictMassage.object(forKey: "profile_picture_url") as! String, email: dictMassage.object(forKey: "email") as! String, login_user_id: dictMassage.object(forKey: "login_user_id") as! String, created_at: dictMassage.object(forKey: "created_at") as! String , is_export : "1",message_date : dictMassage.object(forKey: "created_at") as! String)
                        
                        try! chatModal.insert(db)
                        
                    }
                }
            }
        }
    }
    //        func didFailToSignIn(strMessage: String)
    //        {
    //            print(strMessage)
    //
    //            self.MqttConnectioCheck()
    //        }
    
    
    /// Convert Date to String
    func convertToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let newDate: String = dateFormatter.string(from: date)
        print(newDate)
        
        return newDate
    }
    
    
}

// MARK: Utilites
extension ChatMessageVC {
    
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
}

// MARK: Upload Image on Server

extension ChatMessageVC
{
    func uploadImageFromServer(_ item : [[String: Any]])
    {
        let headerData = NSMutableDictionary()
        
        headerData.setValue(kAuthorizationToken, forKey: "Authorization")
        
        let UserData = NSMutableDictionary()
        
        UserData.setValue("file", forKey:MqttMessageModal.kMessageType)
        UserData.setValue(item[0]["room_id"] as! String , forKey: MqttMessageModal.kRoomId)
        UserData.setValue(item[0]["created_at"] as! String, forKey: MqttMessageModal.kCreatedDate)
        UserData.setValue(item[0]["email"] as! String, forKey: MqttMessageModal.kEmailId)
        UserData.setValue(item[0]["full_name"] as! String, forKey: MqttMessageModal.kFullName)
        UserData.setValue(item[0]["login_user_id"] as! String, forKey:APIParam.kUserId)
        UserData.setValue(item[0]["message_id"] as! String, forKey: MqttMessageModal.kMessageId)
        UserData.setValue(item[0]["profile_picture_url"] as! String, forKey: MqttMessageModal.kProfilePictureUrl)
        
        
        let imagePath = UtilityClass.buildFullPath(forFileName:item[0]["message"] as! String , inDirectory: AppDirectories.ImageCollection)
        
        let image = UIImage(contentsOfFile: imagePath.path)
        if image == nil  {
            
            return
        }
        
        
        APIManager.uploadImageRequest(url:WS_MqttAPI.ChatImageUpload , method:  .post, param: UserData as! [String : String], headers: headerData as! [String : String], image: image!, successComplitionBlock: { (resonce) in
            
            
            if let statusCode = resonce[kStatusCode] as? Int
            {
                if statusCode == APIParam.kStatusSuccess
                {
                    let dictData = resonce["result"] as? NSDictionary
                    print("dictData==   \(dictData as Any)")
                    
                    if dictData != nil
                    {
                        self.updateImageOnDataBase(item[0]["message_id"] as! String , dictData!)
                    }
                }
            }
        }) { (error) in
            
            print("Error")
        }
    }
    
    func updateImageOnDataBase(_ messageId : String , _ dictData : NSDictionary )
    {
        try! dbPool.write { db in
            if var chatUpdate = try chatDataModal.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [messageId]) {
                chatUpdate.is_export = "1"
                chatUpdate.message = dictData.object(forKey: "message") as! String
                try chatUpdate.update(db)
            }
        }
    }
    
}
/*
 
 */
// MARK: Retrive Offline Receiver Message
extension ChatMessageVC
{
    //    func ReceiverDataFetchAPIManager(_ strLastDate : String)
    //    {
    //
    //        let headerData = NSMutableDictionary()
    //
    //        headerData.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMDQ0MjhmNC04NmY0LWI4MTctOWNlNS01YTRhMDdiMDhlZDUiLCJpc3MiOiJodHRwOi8vMTkyLjE2OC4xMC4yMjE6NjE2MS9hcGkvdjEvbG9naW4iLCJpYXQiOjE1MzY3NDQ4NjIsImV4cCI6MTUzNjc0ODQ2MiwibmJmIjoxNTM2NzQ0ODYyLCJqdGkiOiJDMnFBU3dGZmpndHoyVU94In0.LfQkMlLFyTF_axluisO-u60pdau5aqKL_Z1whC_hcLU", forKey: "Authorization")
    //
    //        let UserData = NSMutableDictionary()
    //
    //        UserData.setValue(APIParam.kDeviceIdValue, forKey: APIParam.kDeviceId)
    //        UserData.setValue(APIParam.kPushRegistrationIdValue, forKey: APIParam.kPushRegistrationId)
    //        UserData.setValue(APIParam.kAppVersionValue, forKey: APIParam.kAppVersion)
    //        UserData.setValue(APIParam.kDeviceTypeValue, forKey: APIParam.kDeviceType)
    //        UserData.setValue(APIParam.kOsVersionValue, forKey: APIParam.kOsVersion)
    //     //   UserData.setValue(kLoginUserId, forKey:APIParam.kUserId)
    //          UserData.setValue(SharedManager.sharedInstance.userProfile.user_id!, forKey:APIParam.kUserId)
    //
    //        UserData.setValue(strLastDate, forKey: APIParam.kLastMessageDate)
    //
    //        WSManager.wscallAlamoRequest(url:WS_MqttAPI.FetchUserMessages , method: .post, param: UserData as! [String : String], headers: headerData as! [String : String] , successComplitionBlock: {
    //            (resonce) in
    //
    //            if let statusCode = resonce[kStatusCode] as? Int
    //            {
    //                if statusCode == APIParam.kStatusSuccess
    //                {
    //                    let dataArray = resonce["result"] as? NSArray
    //                    print(dataArray as Any)
    //
    //                    if dataArray != nil
    //                    {
    //                        for item in dataArray!
    //                        {
    //                            let dictData = item as! NSDictionary
    //
    //                            self.offlineUserDataUpdate(dictData)
    //                        }
    //                    }
    //                }
    //
    //            }
    //        }) { (error) in
    //
    //        }
    //
    //    }
    func ReceiverDataFetchAPIManager(_ strLastDate : String , _ messageArray : NSMutableArray)
    {
        
        print("ReceiverDataFetchAPIManager")
        let headerData = NSMutableDictionary()
     //   let secretToken = "Bearer " + Helper.getPREF(UserDefaultsConstant.PREF_SECRET_TOKEN)!
        
        //  headerData.setValue(kAuthorizationToken, forKey: "Authorization")
        
      //  headerData.setValue(secretToken, forKey: "Authorization")
        headerData.setValue(kAuthorizationToken, forKey: "Authorization")

        
        let UserData = NSMutableDictionary()
        
        if messageArray.count > 0
        {
            UserData.setValue(messageArray, forKey: "message_list")
        }
        
        UserData.setValue(APIParam.kDeviceIdValue, forKey: APIParam.kDeviceId)
        UserData.setValue(APIParam.kPushRegistrationIdValue, forKey: APIParam.kPushRegistrationId)
        UserData.setValue(APIParam.kAppVersionValue, forKey: APIParam.kAppVersion)
        UserData.setValue(APIParam.kDeviceTypeValue, forKey: APIParam.kDeviceType)
        UserData.setValue(APIParam.kOsVersionValue, forKey: APIParam.kOsVersion)
        UserData.setValue(kLoginUserId, forKey:APIParam.kUserId)
        UserData.setValue(strLastDate, forKey: APIParam.kLastMessageDate)
        
        WSManager.wscallAlamoRequest(url:WebService.FetchUserMessages , method: .post, param: UserData as! [String : Any], headers: headerData as! [String : String] , successComplitionBlock: {
            (resonce) in
            
            if let statusCode = resonce[kStatusCode] as? Int
            {
                if statusCode == APIParam.kStatusSuccess
                {
                    let dataArray = resonce["result"] as? NSArray
                      print("ReceiverDataFetchAPIManager -- \(dataArray as Any)")
                    
                    if messageArray.count > 0
                    {
                        for item in messageArray
                        {
                            let dictData = item as! NSDictionary
                            
                            self.offlineUserDataUpdate(dictData)
                        }
                    }
                    
                    if dataArray != nil
                    {
                        for item in dataArray!
                        {
                            let dictData = item as! NSDictionary
                            
                            self.offlineUserDataUpdate(dictData)
                        }
                    }
                }
            }
        }) { (error) in
            
        }
        
    }
    
    func offlineUserDataUpdate(_ dictMassage : NSDictionary)
    {
        if dictMassage.object(forKey: "message_id") != nil
        {
            let strMessage_id : String = dictMassage.object(forKey: "message_id") as! String
            let strlogin_user_id : String = dictMassage.object(forKey: "login_user_id") as! String
            
            try! dbPool.read { db in
                if let row = try Row.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                    
                    let dict : NSDictionary = Dictionary(
                        row.map { (column, dbValue) in
                            (column, dbValue.storage.value as AnyObject)
                        },
                        uniquingKeysWith: { (_, right) in right }) as NSDictionary
                    
                    try dbPool.write { db in
                        if var chatUpdate = try chatDataModal.fetchOne(db, "SELECT * FROM chatDataModal WHERE message_id = ?", arguments: [strMessage_id]) {
                            chatUpdate.is_export = "1"
                            try chatUpdate.update(db)
                        }
                    }
                    print("Offline Dict :=== \(dict)")
                }else
                {
                    
                    if let row = try Row.fetchOne(db, "SELECT * FROM hc_user_profile WHERE user_id  = ?", arguments: [strlogin_user_id]) {
                        
                        let dict : NSDictionary = Dictionary(
                            row.map { (column, dbValue) in
                                (column, dbValue.storage.value as AnyObject)
                            },
                            uniquingKeysWith: { (_, right) in right }) as NSDictionary
                        
                        print("strlogin_user_id dict=====\(dict)")
                        
                        try! dbPool.write { db in
                            
                            var chatModal = chatDataModal(id: nil, message_id: dictMassage.object(forKey: "message_id") as! String, message_type: dictMassage.object(forKey: "message_type") as! String, message: dictMassage.object(forKey: "message") as! String, full_name: dict.object(forKey: "full_name") as! String, action: "store" , type: dictMassage.object(forKey: "message_type") as! String, project: "HomeCare", original_file_name: "1", room_id: dictMassage.object(forKey: "room_id") as! String, profile_picture_url: "ashwin.png", email: "ashwin.vafgama@jini.net" , login_user_id: dictMassage.object(forKey: "login_user_id") as! String, created_at: dictMassage.object(forKey: "created_at") as! String , is_export : "1",message_date : dictMassage.object(forKey: "created_at") as! String)
                            
                            try! chatModal.insert(db)
                        }
                    }
                    //                    self.tempDBQuery(roomId: self.strRoomId)
                }
            }
        }
    }
}
extension ChatMessageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePickerController(picker, pickedImage: image)
        
        self.createImagesFolder()
        
        if #available(iOS 11.0, *) {
            if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
                let ImagePath = documentsPath.appendingPathComponent(AppDirectories.ImageCollection.rawValue) as NSString
                let localPath = ImagePath.appendingPathComponent(imgName)
                
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                let data = image.pngData()! as NSData
                data.write(toFile: localPath, atomically: true)
                print(localPath)
                
                //   let photoURL = URL.init(fileURLWithPath: localPath!)
                //                let imageData = NSData(contentsOfFile: localPath)!
                //                let imageWithData = UIImage(data: imageData as Data)!
                
                let messageId = String.random(36)
                
                let createdDate = self.convertToString(date: Date())
                
                try! dbPool.write { db in
                    var chatModal = chatDataModal(id: nil, message_id: messageId, message_type: "file", message: imgName, full_name: "Rajvi Turakhia", action: "message", type: "store", project: "HOMECARE", original_file_name: "1", room_id: ChannelName, profile_picture_url: "ashwinbhai.png", email: "rajvi.turakhia@jini.guru", login_user_id: kLoginUserId, created_at: createdDate, is_export : "0",message_date : createdDate)
                    
                    try! chatModal.insert(db)
                    
                }
                try! dbPool.read { db in
                    
                    let chatArray = NSMutableArray()
                    
                    let request = chatDataModal.filter(Column("is_export") == "0")
                    let count = try! request.fetchCount(db)
                    let AllChat = try! request.fetchAll(db)
                    
                    if count > 0
                    {
                        for item in AllChat
                        {
                            let chatData = item
                            if chatData.message_type  == "file"
                            {
                                let dict : NSDictionary = Dictionary(
                                    chatData.databaseDictionary.map { (column, dbValue) in
                                        (column, dbValue.storage.value as AnyObject)
                                    },
                                    uniquingKeysWith: { (_, right) in right }) as NSDictionary
                                
                                chatArray.add(dict)
                                
                                if chatArray.count == count
                                {
                                    let chatLastData1 = AllChat.last
                                    
                                    if chatLastData1?.created_at != nil{
                                        self.ReceiverDataFetchAPIManager((chatLastData1?.created_at)! , chatArray)
                                    }
                                }
                            }
                        }
                    }
                    else{
                        // if chatLastData?.created_at != nil{
                        self.ReceiverDataFetchAPIManager("2019-04-02 11:30:30" , chatArray)
                        //}
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
        dismiss(animated: true, completion: nil)
    }
    
    private func createImagesFolder() {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            let imagesDirectoryPath = documentDirectoryPath.appending("/\(AppDirectories.ImageCollection.rawValue)")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
        }
    }
}

extension String {
    
    //    static func random(length: Int = 20) -> String {
    //        let base = "abcdef-ghijklmno-pqrstuvwxyz-ABCDEFGHIJK-LMNOPQRSTU-VWXYZ-012345-6789"
    //        var randomString: String = ""
    //
    //        for _ in 0..<length {
    //            let randomValue = arc4random_uniform(UInt32(base.count))
    //            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    //        }\
    //        return randomString
    //    }
}






//
//    var replyView: ReplyView!
//    var replyString: String = ""
//
//    var dataController = ChatDataController()
//    var searchResult: [String: Any] = [:]
//
//    var closeSidebarAfterSubscriptionUpdate = false
//
//    var isRequestingHistory = false
//    var isAppendingMessages = false
//
//var subscriptionToken: NotificationToken?
//    var strRoomId : String?{
//        didSet{
//            subscribeToSelectedRoom()
//        }
//    }
//
//    let socketHandlerToken = String.random(5)
//    var messagesToken: NotificationToken!
//    var messagesQuery: Results<Message>!
//    var messages: [Message] = []
//var subscription: Subscription? {
//    didSet {
//        subscriptionToken?.invalidate()
//
//        guard
//            let subscription = subscription,
//            !subscription.isInvalidated
//            else {
//                return
//        }

//            if !SocketManager.isConnected() {
//                socketDidDisconnect(socket: SocketManager.sharedInstance)
//                ChatDAO._sharedInstance.reconnect()
//            }

//            subscriptionToken = subscription.observe { [weak self] changes in
//                switch changes {
//                case .change(let propertyChanges):
//                    propertyChanges.forEach {
//                        if $0.name == "roomReadOnly" || $0.name == "roomMuted" {
//                            self?.updateMessageSendingPermission()
//                        }
//                    }
//                default:
//                    break
//                }
//            }
//
//            if let oldValue = oldValue {
//                if oldValue.identifier != subscription.identifier {
//                    emptySubscriptionState(isHide: true)
//                }
//            } else {
//                emptySubscriptionState(isHide: true)
//            }
//
//            updateSubscriptionInfo()
//            markAsRead()
//            typingIndicatorView?.dismissIndicator()
//
//            if let oldValue = oldValue, oldValue.identifier != subscription.identifier {
//                //                unsubscribe(for: oldValue)
//            }
//
//            textView.text = DraftMessageManager.draftMessage(for: subscription)
//  }
//}
//
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
//        SocketManager.removeConnectionHandler(token: socketHandlerToken)
//        messagesToken?.invalidate()
//
//        subscriptionToken?.invalidate()
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func viewDidLoad() {
//
//        super.viewDidLoad()
//
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = UIColor.white
//        navigationController?.navigationBar.tintColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)
//
//
//
//        setupTextViewSettings()
//
//
//        registerCells()
//    }
//
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        guard let collectionView = collectionView else { return }
//
//        var contentInsets = collectionView.contentInset
//        contentInsets.bottom =  0
//        if #available(iOS 11, *) {
//            contentInsets.right = collectionView.safeAreaInsets.right
//            contentInsets.left = collectionView.safeAreaInsets.left
//        }
//        collectionView.contentInset = contentInsets
//
//        var scrollIndicatorInsets = collectionView.scrollIndicatorInsets
//        scrollIndicatorInsets.right = 0
//        scrollIndicatorInsets.left = 0
//        scrollIndicatorInsets.bottom = 0
//        collectionView.scrollIndicatorInsets = scrollIndicatorInsets
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        coordinator.animate(alongsideTransition: nil, completion: { _ in
//            self.collectionView?.collectionViewLayout.invalidateLayout()
//        })
//    }
//
fileprivate func subscribeToSelectedRoom(){
    
    // This method will re subscribe
    //
    //        guard let auth = AuthManager.isAuthenticated() else { return }
    //        let subscriptions = auth.subscriptions.filter("rid == '\(strRoomId ?? "GENERAL")'").sorted(byKeyPath: "lastSeen", ascending: false)
    //
    //        if let subscription = subscriptions.first {
    //            self.subscription = subscription
    //        }else{
    //            self.subscription = nil
    //            //            lblNoLabel.text = "No Room Found"
    //            clearListData(isHide: false)
    //        }
}

//
//    fileprivate func shodHideNoDataFoundView(isHide : Bool){
//
//        //        collectionView?.backgroundView = viewNoDataFound
//
//        self.viewNoDataFound.isHidden = isHide
//    }
//
//    fileprivate func setupTextViewSettings() {
//
//        //         Apply corner radius to text view
//        textView.layer.cornerRadius = 5.0
//        textView.clipsToBounds = true
//        textView.layer.masksToBounds = true
//        textView.layer.borderWidth = 1.0
//        textView.layer.borderColor = UIColor.black.cgColor
//
//        // Register Symbols to textview
//        textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
//        textView.registerMarkdownFormattingSymbol("_", withTitle: "Italic")
//        textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
//        textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
//        textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
//        textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
//
//        textView.setPlaceholder(placeHolderText: StringMessages.STR_TYPE_YOUR_MESSAGE)
//
//        registerPrefixes(forAutoCompletion: ["@", "#"])
//    }
//
//    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
//        return ChatCollectionViewFlowLayout()
//    }
//
//    fileprivate func registerCells() {
//
//        collectionView?.register(UINib(
//            nibName: "ChatMessageDaySeparator",
//            bundle: Bundle.main
//        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)
//
//        collectionView?.register(UINib(
//            nibName: "SenderMessageCollectionViewCell",
//            bundle: Bundle.main
//        ), forCellWithReuseIdentifier: SenderMessageCollectionViewCell.identifier)
//
//        collectionView?.register(UINib(
//            nibName: "ReceieverMessageCollectionViewCell",
//            bundle: Bundle.main
//        ), forCellWithReuseIdentifier: ReceieverMessageCollectionViewCell.identifier)
//
//        collectionView?.register(UINib(
//            nibName: "ChatMessageReceiverImageCell",
//            bundle: Bundle.main
//        ), forCellWithReuseIdentifier: ChatMessageReceiverImageCell.identifier)
//
//        collectionView?.register(UINib(
//            nibName: "ChatMessageSenderImageCell",
//            bundle: Bundle.main
//        ), forCellWithReuseIdentifier: ChatMessageSenderImageCell.identifier)
//
//        autoCompletionView.register(UINib(
//            nibName: "AutocompleteCell",
//            bundle: Bundle.main
//        ), forCellReuseIdentifier: AutocompleteCell.identifier)
//
//    }
//
//    internal func scrollToBottom(_ animated: Bool = false) {
//        let boundsHeight = collectionView?.bounds.size.height ?? 0
//        let sizeHeight = collectionView?.contentSize.height ?? 0
//        let offset = CGPoint(x: 0, y: max(sizeHeight - boundsHeight, 0))
//        collectionView?.setContentOffset(offset, animated: animated)
//    }
//
//    // MARK: SlackTextViewController
//
//    override func canPressRightButton() -> Bool {
//        return true
//    }
//
//    @IBAction func btnSendMessageTapped(_ sender: UIButton) {
//        sendMessage()
//    }
//
//    override func didPressRightButton(_ sender: Any?) {
//        sendMessage()
//    }
//
//    override func didPressLeftButton(_ sender: Any?) {
//        buttonUploadDidPressed()
//    }
//
//    override func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
//        sendMessage()
//    }
//
//    override func textViewDidBeginEditing(_ textView: UITextView) {
//        scrollToBottom(true)
//    }
//
//    override func textViewDidChange(_ textView: UITextView) {
//        //        guard let subscription = self.subscription else { return }
//
//        textView.hidePlaceHolderIfNeeded()
//
//        //        DraftMessageManager.update(draftMessage: textView.text, for: subscription)
//        //
//        //        if textView.text?.isEmpty ?? true {
//        //            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
//        //        } else {
//        //            SubscriptionManager.sendTypingStatus(subscription, isTyping: true)
//        //        }
//
//    }
//
//    override func textViewDidEndEditing(_ textView: UITextView) {
//        textView.resignFirstResponder()
//
//        sendMessage()
//        //        setupBottomViewToDefaultFrames()
//    }
//
//    // MARK: Message
//    fileprivate func sendMessage() {
//        guard let subscription = subscription else { return }
//        guard let messageText = textView.text, messageText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return }
//
//        let replyString = self.replyString
//        stopReplying()
//
//        self.scrollToBottom()
//        rightButton.isEnabled = false
//
//        var message: Message?
//        Realm.executeOnMainThread({ (realm) in
//            message = Message()
//            message?.internalType = ""
//            message?.createdAt = Date.serverDate
//            message?.text = "\(messageText)\(replyString)"
//            message?.subscription = subscription
//            message?.identifier = String.random(18)
//            message?.temporary = true
//            message?.user = AuthManager.currentUser()
//            message?.isRead = 1
//            message?.isExport = 0
//            message?.internalType = "t"
//            message?.rid = subscription.rid
//            message?.markedForDeletion = false
//            print("subscription\(subscription.identifier)")
//            if let message = message {
//                realm.add(message)
//            }
//        })
//
//        if let message = message {
//            textView.text = ""
//            textView.hidePlaceHolderIfNeeded()
//            rightButton.isEnabled = true
//            Realm.executeOnMainThread({ (realm) in
//                message.temporary = false
//                realm.add(message, update: true)
//            })
//        }
//    }
//
//    fileprivate func chatLogIsAtBottom() -> Bool {
//        guard let collectionView = collectionView else { return false }
//
//        let height = collectionView.bounds.height
//        let bottomInset = collectionView.contentInset.bottom
//        let scrollContentSizeHeight = collectionView.contentSize.height
//        let verticalOffsetForBottom = scrollContentSizeHeight + bottomInset - height
//
//        return collectionView.contentOffset.y >= (verticalOffsetForBottom - 1)
//    }
//
//    fileprivate func sendPinnedMessage(message: Message){
//        UIAlertController().showAlertController(viewcontroller: self, title: "Select Type", message: "", buttons: ["\(PinnedPriority.Important)","\(PinnedPriority.Work)","\(PinnedPriority.Personal)","\(PinnedPriority.ToDO)","\(PinnedPriority.Normal)"], type: .actionSheet) { (index,btn) in
//            let priority = PinnedPriority.getIntrawValue(strType: btn)
//            MessageManager.pinMessage(message, pinnedPriority: priority, completion: { (response) in
//                //                message.pinned = true
//                //                message.pinnedPriority = priority
//                //                print(response)
//            })
//            //self.sendMessage()
//        }
//    }
//
//    // MARK: Subscription
//
//    fileprivate func markAsRead() {
//        //        guard let subscription = subscription else { return }
//
//        //        SubscriptionManager.markAsRead(subscription) { _ in
//        //            // Nothing, for now
//        //        }
//    }
//
//    //    internal func unsubscribe(for subscription: Subscription) {
//    //        SocketManager.unsubscribe(eventName: subscription.rid)
//    //        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
//    //    }
//
//    internal func emptySubscriptionState(isHide : Bool) {
//        clearListData(isHide: isHide)
//        updateJoinedView()
//        //        textView.resignFirstResponder()
//    }
//
//    internal func updateJoinedView() {
//        guard let subscription = subscription else { return }
//
//        if subscription.isJoined() {
//            setTextInputbarHidden(false, animated: false)
//        } else {
//            setTextInputbarHidden(true, animated: false)
//        }
//    }
//
//    internal func clearListData(isHide: Bool) {
//        collectionView?.performBatchUpdates({
//            let indexPaths = self.dataController.clear()
//            self.collectionView?.deleteItems(at: indexPaths)
//        }, completion: { _ in
//            CATransaction.commit()
//            self.shodHideNoDataFoundView(isHide: isHide)
//        })
//    }
//
//    internal func updateSubscriptionInfo() {
//        guard let subscription = subscription else { return }
//
//        messagesToken?.invalidate()
//
//
//        //        title = subscription.displayName()
//        //        chatTitleView?.subscription = subscription
//
//        if subscription.isValid() {
//            updateSubscriptionMessages()
//        } else {
//            subscription.fetchRoomIdentifier({ [weak self] response in
//                self?.subscription = response
//            })
//        }
//
//        updateMessageSendingPermission()
//    }
//
//    internal func updateSubscriptionMessages() {
//        guard let subscription = subscription else { return }
//
//        messagesQuery = subscription.fetchMessagesQueryResults(strRoomId: strRoomId)
//        dataController.loadedAllMessages = false
//        isRequestingHistory = false
//        updateMessagesQueryNotificationBlock()
//        loadMoreMessagesFrom(date: nil)
//    }
//
//    func checkIfMessageIsDeleted(){
//
//        guard let realm = Realm.shared else { return }
//
//        let deletedMessages = Array(realm.objects(Message.self).filter("markedForDeletion == true && rid == '\(subscription?.rid ?? "GENERAL")'"))
//
//        if(deletedMessages.count > 0){
//
//            for messages in deletedMessages{
//
//                if let index = self.dataController.delete(msgId: messages.identifier ?? ""){
//
//                    self.dataController.data.remove(at: index)
//
//                    UIView.performWithoutAnimation {
//
//                        self.collectionView?.performBatchUpdates({
//                            self.collectionView?.deleteItems(at:[IndexPath(row: index, section: 0)])
//                        }) { (finished) in
//                            if(self.dataController.data.count == 0){
//                                self.shodHideNoDataFoundView(isHide: false)
//                            }
//                            self.collectionView?.layoutIfNeeded()
//                        }
//
//                        try! realm.write {
//                            realm.delete(realm.objects(Message.self).filter("markedForDeletion == true && identifier == '\(messages.identifier ?? "")'"))
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    fileprivate func updateMessagesQueryNotificationBlock() {
//        messagesToken?.invalidate()
//
//        messagesToken = messagesQuery.observe { [unowned self] changes in
//
//            switch changes {
//
//            case .update(_, let deletions, let insertions,let modifications):
//
//                print("Deletion Message \(deletions.count)")
//                print("Insertion Message \(insertions.count)")
//                print("Modidication Message \(modifications.count)")
//
//                if deletions.count > 0{
//
//                    UIView.performWithoutAnimation {
//                        //                        let lastIndexPath = self.dataController.data.last?.indexPath.item
//                        //
//                        //                        self.dataController.data.remove(at: lastIndexPath!)
//                        //
//                        //                        self.collectionView?.performBatchUpdates({
//                        //                            self.collectionView?.deleteItems(at:[IndexPath(row: lastIndexPath!, section: 0)])
//                        //                        }) { (finished) in
//                        //
//                        //                            if(self.dataController.data.count == 0){
//                        //                                self.shodHideNoDataFoundView(isHide: false)
//                        //                            }
//                        //
//                        //                            self.collectionView?.reloadData()
//                        //                        }
//                    }
//                }
//
//                if insertions.count > 0 {
//                    var newMessages: [Message] = []
//                    for insertion in insertions {
//                        guard insertion < self.messagesQuery.count else { continue }
//                        let newMessage = Message(value: self.messagesQuery[insertion])
//                        newMessages.append(newMessage)
//                    }
//
//                    self.messages.append(contentsOf: newMessages)
//                    self.appendMessages(messages: newMessages, completion: {
//
//                    })
//                }
//
//                //                if modifications.count == 0 {
//                //                    return
//                //                }
//
//                if modifications.count > 0 {
//                    let isAtBottom = self.chatLogIsAtBottom()
//
//                    var indexPathModifications: [Int] = []
//
//                    for modified in modifications {
//                        guard modified < self.messagesQuery.count else { continue }
//
//                        let message = Message(value: self.messagesQuery[modified])
//
//                        if(message.markedForDeletion){
//                            self.checkIfMessageIsDeleted()
//                        }
//
//                        let index = self.dataController.update(message)
//
//                        if index >= 0 && !indexPathModifications.contains(index) {
//                            indexPathModifications.append(index)
//                        }
//                    }
//
//                    if indexPathModifications.count > 0 {
//                        UIView.performWithoutAnimation {
//                            self.collectionView?.performBatchUpdates({
//                                self.collectionView?.reloadItems(at: indexPathModifications.map { IndexPath(row: $0, section: 0) })
//                            }, completion: { _ in
//
//                                if(self.dataController.data.count == 0){
//                                    self.shodHideNoDataFoundView(isHide: false)
//                                }
//
//                                if isAtBottom {
//                                    self.scrollToBottom()
//                                }
//                            })
//                        }
//                    }
//                }
//
//            default :
//                print("")
//            }
//        }
//    }
//
//    fileprivate func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
//        guard let subscription = subscription else { return }
//
//        if isRequestingHistory || dataController.loadedAllMessages {
//            return
//        }
//
//        isRequestingHistory = true
//
//        let newMessages = subscription.fetchMessages(strRoomId: strRoomId, lastMessageDate: date).map({ Message(value: $0) })
//        if newMessages.count > 0 {
//
//            messages.append(contentsOf: newMessages)
//            appendMessages(messages: newMessages, completion: { [weak self] in
//
//                self?.isRequestingHistory = false
//
//                if date == nil {
//                    self?.scrollToBottom()
//                }
//            })
//        }
//    }
//
//    fileprivate func appendMessages(messages: [Message], completion: VoidCompletion?) {
//        guard
//            let subscription = subscription,
//            let collectionView = collectionView
//            else {
//                return
//        }
//
//        guard !isAppendingMessages else {
//            Log.debug("[APPEND MESSAGES] Blocked trying to append \(messages.count) messages")
//
//            // This message can be called many times during the app execution and we need
//            // to call them one per time, to avoid adding the same message multiple times
//            // to the list. Also, we keep the subscription identifier in order to make sure
//            // we're updating the same subscription, because this view controller is reused
//            // for all the chats.
//            let oldSubscriptionIdentifier = subscription.identifier
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
//                guard oldSubscriptionIdentifier == self?.subscription?.identifier else { return }
//                self?.appendMessages(messages: messages, completion: completion)
//            })
//            return
//        }
//
//        isAppendingMessages = true
//
//        var tempMessages: [Message] = []
//        for message in messages {
//            tempMessages.append(Message(value: message))
//        }
//
//        DispatchQueue.global(qos: .background).async {
//            var objs: [ChatData] = []
//            var newMessages: [Message] = []
//
//            // Do not add duplicated messages
//            for message in tempMessages {
//                var insert = true
//
//                for obj in self.dataController.data where message.identifier == obj.message?.identifier {
//                    insert = false
//                }
//
//                if insert {
//                    newMessages.append(message)
//                }
//            }
//
//            // Normalize data into ChatData object
//            for message in newMessages {
//                guard let createdAt = message.createdAt else { continue }
//                var obj = ChatData(type: .message, timestamp: createdAt)
//                obj.message = message
//                objs.append(obj)
//            }
//
//            // No new data? Don't update it then
//            if objs.count == 0 {
//
//                DispatchQueue.main.async {
//                    self.isAppendingMessages = false
//                    self.shodHideNoDataFoundView(isHide: true)
//                    completion?()
//                }
//
//                return
//            }
//
//            DispatchQueue.main.async {
//                collectionView.performBatchUpdates({
//                    let (indexPaths, removedIndexPaths) = self.dataController.insert(objs)
//                    collectionView.insertItems(at: indexPaths)
//                    collectionView.deleteItems(at: removedIndexPaths)
//                }, completion: { _ in
//
//                    self.isAppendingMessages = false
//                    self.shodHideNoDataFoundView(isHide: true)
//
//                    completion?()
//                })
//            }
//        }
//    }
//
//    fileprivate func isContentBiggerThanContainerHeight() -> Bool {
//        if let contentHeight = self.collectionView?.contentSize.height {
//            if let collectionViewHeight = self.collectionView?.frame.height {
//                if contentHeight < collectionViewHeight {
//                    return false
//                }
//            }
//        }
//
//        return true
//    }
//
//    // MARK: IBAction
//
//    @objc func chatTitleViewDidPressed(_ sender: AnyObject) {
//        performSegue(withIdentifier: "Channel Info", sender: sender)
//    }
//}
//
//// MARK: UIcollectionViewDataSource
//
//extension ChatMessageVC {
//
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row < 4 {
//            if let message = dataController.oldestMessage() {
//                loadMoreMessagesFrom(date: message.createdAt)
//            }
//        }
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //        print("Total Message \(dataController.data.count)")
//
//        return dataController.data.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard
//            dataController.data.count > indexPath.row,
//            //            let subscription = subscription,
//            let obj = dataController.itemAt(indexPath),
//            !(obj.message?.isInvalidated ?? false)
//            else {
//                return UICollectionViewCell()
//        }
//
//        if obj.type == .message {
//            return cellForMessage(obj, at: indexPath)
//        }
//
//        if obj.type == .daySeparator {
//            return cellForDaySeparator(obj, at: indexPath)
//        }
//
//        return UICollectionViewCell()
//    }
//
//    // MARK: Cells
//
//    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
//
//        // Check if message is for logged in user or for any other user
//
//        if(obj.message?.user?.identifier == AuthManager.currentUser()?.identifier){
//            return cellForMessageReceiverUser(obj, at: indexPath)
//        } else{
//            return cellForMessageSenderUser(obj, at: indexPath)
//        }
//
//    }
//
//    func cellForMessageSenderUser(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell{
//
//        if(obj.message?.type == .image){
//
//            guard let senderImageCell = collectionView?.dequeueReusableCell(
//                withReuseIdentifier: ChatMessageSenderImageCell.identifier,
//                for: indexPath
//                ) as? ChatMessageSenderImageCell else {
//                    return UICollectionViewCell()
//            }
//
//            return cellForSenderImageCell(cell: senderImageCell, obj, at: indexPath)
//
//        }else{
//
//            guard let senderCell = collectionView?.dequeueReusableCell(
//                withReuseIdentifier: SenderMessageCollectionViewCell.identifier,
//                for: indexPath
//                ) as? SenderMessageCollectionViewCell else {
//                    return UICollectionViewCell()
//            }
//
//            return cellForSenderMessage(cell: senderCell, obj, at: indexPath)
//        }
//
//    }
//
//    func cellForMessageReceiverUser(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell{
//
//        if(obj.message?.type == .image){
//
//            guard let receieverImageCell = collectionView?.dequeueReusableCell(
//                withReuseIdentifier: ChatMessageReceiverImageCell.identifier,
//                for: indexPath
//                ) as? ChatMessageReceiverImageCell else {
//                    return UICollectionViewCell()
//            }
//
//            return cellForReceiverImageCell(cell: receieverImageCell, obj, at: indexPath)
//        }else{
//
//            guard let receieverCell = collectionView?.dequeueReusableCell(
//                withReuseIdentifier: ReceieverMessageCollectionViewCell.identifier,
//                for: indexPath
//                ) as? ReceieverMessageCollectionViewCell else {
//                    return UICollectionViewCell()
//            }
//
//            return cellForReceieverMessage(cell: receieverCell, obj, at: indexPath)
//        }
//
//    }
//
//    func cellForSenderMessage(cell : SenderMessageCollectionViewCell,_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
//
//        cell.delegate = self
//
//        if let message = obj.message {
//            cell.message = message
//        }
//
//        cell.sequential = dataController.hasSequentialMessageAt(indexPath)
//        return cell
//
//    }
//
//    func cellForReceieverMessage(cell : ReceieverMessageCollectionViewCell,_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell{
//
//        cell.delegate = self
//
//        if let message = obj.message {
//            cell.message = message
//        }
//
//        cell.sequential = dataController.hasSequentialMessageAt(indexPath)
//
//        return cell
//    }
//
//    func cellForSenderImageCell(cell : ChatMessageSenderImageCell,_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell{
//
//        if let message = obj.message {
//            cell.message = message
//        }
//
//        cell.delegate = self
//
//        cell.sequential = dataController.hasSequentialMessageAt(indexPath)
//
//        return cell
//    }
//
//    func cellForReceiverImageCell(cell : ChatMessageReceiverImageCell,_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell{
//
//        if let message = obj.message {
//            cell.message = message
//        }
//
//        cell.delegate = self
//
//        cell.sequential = dataController.hasSequentialMessageAt(indexPath)
//
//        return cell
//    }
//
//    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView?.dequeueReusableCell(
//            withReuseIdentifier: ChatMessageDaySeparator.identifier,
//            for: indexPath
//            ) as? ChatMessageDaySeparator else {
//                return UICollectionViewCell()
//        }
//
//        cell.labelTitle.layer.cornerRadius =  10
//        cell.labelTitle.clipsToBounds = true
//
//        if(obj.timestamp.isDateInToday(date: obj.timestamp)){
//            cell.labelTitle.text = "Today"
//        }else if(obj.timestamp.isDateInYesterday(date: obj.timestamp)){
//            cell.labelTitle.text = "Yesterday"
//        }else{
//            cell.labelTitle.text = obj.timestamp.formatted("EEEE, MMMM dd, YYYY")
//        }
//
//        cell.viewBackground.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "straws_bg"))
//        return cell
//    }
//}
//
//// MARK: UIcollectionViewDelegateFlowLayout
//
//extension ChatMessageVC: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return .zero
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        var fullWidth = collectionView.bounds.size.width
//
//        if #available(iOS 11, *) {
//            fullWidth -= collectionView.safeAreaInsets.right + collectionView.safeAreaInsets.left
//        }
//
//        if let obj = dataController.itemAt(indexPath) {
//
//            if obj.type == .daySeparator {
//                return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
//            }
//
//            if let message = obj.message {
//
//                let sequential = dataController.hasSequentialMessageAt(indexPath)
//
//                // Calculate height by message type. Exmaple message type can be sender , receiever , image
//
//                if(obj.message?.user?.identifier == AuthManager.currentUser()?.identifier){
//
//                    if(obj.message?.type == .image){
//
//                        return CGSize(width: fullWidth, height: ChatMessageReceiverImageCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: sequential))
//
//                    }else{
//                        return CGSize(width: fullWidth, height: ReceieverMessageCollectionViewCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: sequential))
//                    }
//                }else{
//
//                    if(obj.message?.type == .image){
//                        return CGSize(width: fullWidth, height: ChatMessageSenderImageCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: sequential))
//                    }else{
//                        return CGSize(width: fullWidth, height: SenderMessageCollectionViewCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: sequential))
//                    }
//                }
//            }
//        }
//
//        return CGSize(width: fullWidth, height: 40)
//    }
//}
//
//// MARK: UIScrollViewDelegate
//
//extension ChatMessageVC {
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        super.scrollViewDidScroll(scrollView)
//
//        if scrollView.contentOffset.y < -10 {
//            if let message = dataController.oldestMessage() {
//                loadMoreMessagesFrom(date: message.createdAt)
//            }
//        }
//    }
//}
//
//
//// MARK: Block Message Sending
//
//extension ChatMessageVC {
//
//    fileprivate func updateMessageSendingPermission() {
//        guard
//            let subscription = subscription,
//            let currentUser = AuthManager.currentUser()
//            else {
//                allowMessageSending()
//                return
//        }
//
//        if subscription.roomReadOnly && subscription.roomOwner != currentUser {
//            blockMessageSending(reason: localized("chat.read_only"))
//        } else if let username = currentUser.username, subscription.roomMuted.contains(username) {
//            blockMessageSending(reason: localized("chat.muted"))
//        } else {
//            allowMessageSending()
//        }
//    }
//
//    fileprivate func blockMessageSending(reason: String) {
//        textInputbar.textView.placeholder = reason
//        textInputbar.backgroundColor = .white
//        textInputbar.isUserInteractionEnabled = false
//        leftButton.isEnabled = false
//        rightButton.isEnabled = false
//    }
//
//    fileprivate func allowMessageSending() {
//        textInputbar.textView.placeholder = ""
//        textInputbar.backgroundColor = .backgroundWhite
//        textInputbar.isUserInteractionEnabled = true
//        leftButton.isEnabled = true
//        rightButton.isEnabled = true
//    }
//}
//
//extension ChatMessageVC : SenderMessageCellProtocol{
//
//    func handleSendContainerTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//        sendPinnedMessage(message: message)
//    }
//
//
//    func openURL1(url: URL) {
//
//    }
//
//    func handleLongPressMessageCell1(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//    func handleUsernameTapMessageCell1(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//}
//
//extension ChatMessageVC : ReceieverMessageCellProtocol{
//
//    func handleContainerTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//        sendPinnedMessage(message: message)
//    }
//
//
//    func openURL2(url: URL) {
//
//    }
//
//    func handleLongPressMessageCell2(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//    func handleUsernameTapMessageCell2(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//}
//
//extension ChatMessageVC : ChatMessageSenderImageCellProtocol{
//    func handleSenderImageContainerTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//        sendPinnedMessage(message: message)
//    }
//
//
//    func openURL4(url: URL) {
//
//    }
//
//    func handleLongPressMessageCell4(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//    func handleUsernameTapMessageCell4(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//}
//
//extension ChatMessageVC : ChatMessageReceiverImageCellProtocol{
//    func handleReceiverImageContainerTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//        sendPinnedMessage(message: message)
//    }
//
//
//    func openURL3(url: URL) {
//
//    }
//
//    func handleLongPressMessageCell3(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
//
//    }
//
//    func handleUsernameTapMessageCell3(_ message: Message, view: UIView, recognizer: UIGestureRecognizer){
//
//    }
//}






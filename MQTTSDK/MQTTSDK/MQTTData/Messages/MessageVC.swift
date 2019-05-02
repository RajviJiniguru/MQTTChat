//
//  MessageVC.swift
//  thecareportal
//
//  Created by Jayesh on 23/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
//import SideMenu
//import RealmSwift

enum RoomType : String{
    case Client = "CLIENT"
    case General = "GENERAL"
    case Carer = "CARER"
}

public class MessageVC: ParentVC {
    
    // Iboutlets
    @IBOutlet weak var IBviewContainerChat: UIView!
    @IBOutlet weak var IBviewContainerOffice: UIView!
    
    @IBOutlet weak var IBscrollview : UIScrollView!
    @IBOutlet weak var IBlblChat : UILabel!
    @IBOutlet weak var IBlblOffice : UILabel!
    
    @IBOutlet weak var IBbtnChat: UIButton!
    @IBOutlet weak var IBbtnOffice: UIButton!
    
    @IBOutlet weak var viewContainerMessage: UIView!
    static var chatGeneralVC: ChatMessageVC!
    static var chatPrivateRoomVC : ChatMessageVC!
    
    var multilineTitleNavVc : UILabel!
    
    var defaultSelectedPublicRoomName : String!
    var defaultSelectedPrivateRoomName : String!
    
    var defaultSelectedPublicRoomId : String!
    var defaultSelectedPrivateRoomId : String!
    
    var lastSelectedRoomName : String!
    
    static var lastSelectedRoomId : String?
    
//    static var unreadTotalMessageCountByCategoryToken : NotificationToken!
//
//    var unreadTotalMessageCountByChat : NotificationToken!
//    var unreadTotalMessageCountByOffice : NotificationToken!
    
    lazy var arrOfPrivateRooms : [UserInformarion] = [UserInformarion]()
    lazy var arrOfPublicRooms : [UserInformarion] = [UserInformarion]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        retriveClients()
        
        // Do any additional setup after loading the view.
        
        configureDefaultRoomForChat()
        configureDefaultRoomForOffice()
        setNavigationTitleView()
        
        // This weill update unread message count by tab bar
        updateUnreadMessageCountForTabbar()
        setupDelegateForTabbarChanges()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        // This will update unread message count bny it's own category
        updateUnreadMessageCountByCategory()
        configureViewControllerWithTheme()
        
//        if let leftMenuVC = self.revealViewController().rearViewController as? SideMenuControllerVC{
//            leftMenuVC.delegate = self
//        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        removeRealmNotificationForChatAndOffice()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARk:- Retrive clients
    func retriveClients(){
        if let clientData = DBManager.getClientList(){
            SharedManager.sharedInstance.Clients = clientData
            
            if clientData.count > 0{
                SharedManager.sharedInstance.clientProfile = clientData[0]
            }
        }
    }
    
    func getDefaultPrivateRoom() -> (chatEngineRoomId : String?,chatEngineRoomName : String?) {
        // 27-3 Carer
        if let privateRooms = getDefaultRoomByTypeWise(roomType: RoomType.Client){
            
            for room in privateRooms.enumerated(){
                arrOfPrivateRooms.append(room.element)
            }
        }
        
        if let carerRooms = getDefaultRoomByTypeWise(roomType: RoomType.Carer){
            
            for room in carerRooms.enumerated(){
                room.element.room_name = "Direct Message"
                arrOfPrivateRooms.append(room.element)
            }
        }
        return (arrOfPrivateRooms.first?.chatengine_room_id,arrOfPrivateRooms.first?.room_name)
    }
    
    func getDefaultPublicRoom() -> (chatEngineRoomId : String?,chatEngineRoomName : String?) {
        
        if let arrOfRooms = getDefaultRoomByTypeWise(roomType: RoomType.General){
            
            arrOfPublicRooms = arrOfRooms
            
            return (arrOfPublicRooms.first?.chatengine_room_id, arrOfPublicRooms.first?.room_name)
        }
        
        return (nil,nil)
    }
    
    func getDefaultRoomByTypeWise(roomType : RoomType) -> [UserInformarion]? {
        
           if let arrOfRooms = DBManager.getRoomId(userId: SharedManager.sharedInstance.userProfile.user_id, roomType:roomType.rawValue){
            return arrOfRooms
        }
        return nil
    }
    
    func setDefaultPrivateRoom(){
        
        lastSelectedRoomName = nil
        setSelectedRoomNameOnVC(strRoomName:defaultSelectedPrivateRoomName)
       MessageVC.chatPrivateRoomVC.strRoomId = defaultSelectedPrivateRoomId ?? ""

        updateMessageMarkAsAReadCount(roomId: defaultSelectedPrivateRoomId ?? "")

        MessageVC.lastSelectedRoomId = defaultSelectedPrivateRoomId

        IBlblChat.isHidden = false
        IBlblOffice.isHidden = true
        MessageVC.chatPrivateRoomVC.tempDBQuery(roomId : defaultSelectedPrivateRoomId ?? "")

    }
    
    func setupDefaultPublicRoom(){

        lastSelectedRoomName = nil
        setSelectedRoomNameOnVC(strRoomName: defaultSelectedPublicRoomName)
        MessageVC.chatGeneralVC.strRoomId = defaultSelectedPublicRoomId ?? ""

        updateMessageMarkAsAReadCount(roomId: defaultSelectedPublicRoomId ?? "")

        MessageVC.lastSelectedRoomId = defaultSelectedPublicRoomId

        IBlblChat.isHidden = true
        IBlblOffice.isHidden = false
        MessageVC.chatGeneralVC.tempDBQuery(roomId : defaultSelectedPublicRoomId ?? "")

    }
    
    func setNavigationTitleView(){
        
        multilineTitleNavVc = UILabel(frame: CGRect(x:0, y:0, width:400, height:50))
        multilineTitleNavVc.backgroundColor = .clear
        multilineTitleNavVc.numberOfLines = 2
        multilineTitleNavVc.font = UIFont.boldSystemFont(ofSize: 16.0)
        multilineTitleNavVc.textAlignment = .center
        multilineTitleNavVc.textColor = .white
        multilineTitleNavVc.attributedText = makeAttributedTitle(strRoomName: defaultSelectedPrivateRoomName ?? "")
        self.navigationItem.titleView = multilineTitleNavVc
        
        MessageVC.lastSelectedRoomId = defaultSelectedPrivateRoomId
        
        updateMessageMarkAsAReadCount(roomId: defaultSelectedPrivateRoomId ?? "")
    }
    
    func configureDefaultRoomForChat(){
        
        let arrChatEngineDefaultPrivateRoomDetails = getDefaultPrivateRoom()
        MessageVC.chatPrivateRoomVC.strRoomId = arrChatEngineDefaultPrivateRoomDetails.chatEngineRoomId ?? ""
        defaultSelectedPrivateRoomName = arrChatEngineDefaultPrivateRoomDetails.chatEngineRoomName ?? ""
        defaultSelectedPrivateRoomId = arrChatEngineDefaultPrivateRoomDetails.chatEngineRoomId ?? ""
        MessageVC.chatPrivateRoomVC.tempDBQuery(roomId : defaultSelectedPrivateRoomId ?? "")
    }
    
    func configureDefaultRoomForOffice(){
        let arrChatEngineDefaultPublicRoomDetails = getDefaultPublicRoom()
        MessageVC.chatGeneralVC.strRoomId =  arrChatEngineDefaultPublicRoomDetails.chatEngineRoomId ?? ""
        defaultSelectedPublicRoomName = arrChatEngineDefaultPublicRoomDetails.chatEngineRoomName ?? ""
        defaultSelectedPublicRoomId = arrChatEngineDefaultPublicRoomDetails.chatEngineRoomId ?? ""
    }
    
    func setSelectedRoomNameOnVC(strRoomName : String?){
        if(strRoomName != nil){
            multilineTitleNavVc.attributedText = makeAttributedTitle(strRoomName: strRoomName!)
            self.navigationItem.titleView = multilineTitleNavVc
        }
    }
    
    func setupDelegateForTabbarChanges(){
        self.tabBarController?.delegate = self
    }
    
    func updateMessageMarkAsAReadCount(roomId : String){
        
        // It will make sure to mark as a read in our local database
        ChatDAO._sharedInstance.updateMessageMarkAsAReadCount(rid: roomId)
    }
    
    func dismissKeyboardIfItIsAlreadyOpened(){
        self.view.endEditing(true)
    }
    
    func makeAttributedTitle(strRoomName : String) -> NSMutableAttributedString{
        
        let attributedString : NSMutableAttributedString = NSMutableAttributedString()
        
        let attrStringMessages = NSAttributedString(string: "Messages\n", attributes:[NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 17.0)!])
        
        attributedString.append(attrStringMessages)
        
        let attrStringRoomName = NSAttributedString(string: strRoomName, attributes:[NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 14.0)!])
        
        attributedString.append(attrStringRoomName)
        
        return attributedString
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "Chat"){
            if let chatMessageVC = segue.destination as? ChatMessageVC{
                MessageVC.chatPrivateRoomVC = chatMessageVC
            }
            
        }else if(segue.identifier == "Office"){
            if let chatMessageVC = segue.destination as? ChatMessageVC{
                MessageVC.chatGeneralVC = chatMessageVC
            }
        }
    }
}

// MARK: Custom Methods

extension MessageVC{
    
    func configureViewControllerWithTheme(){
        viewContainerMessage.backgroundColor = ThemeManager.shared.currentTheme().themeColor
    }
}

// MARK:- IBAction Method
extension MessageVC{
    
    @IBAction func onclickChat(_ sender : UIButton){
        
        setDefaultPrivateRoom()
        dismissKeyboardIfItIsAlreadyOpened()
        IBscrollview.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    
    @IBAction func onclickOffice(_ sender : UIButton){
        
        setupDefaultPublicRoom()
        dismissKeyboardIfItIsAlreadyOpened()
        
        IBscrollview.setContentOffset(CGPoint(x:  IBscrollview.bounds.width * 1,y: 0), animated: true)
    }
    
    @IBAction func onclickSearch(_ sender : UIButton){
        
        guard let messageFiltervc = self.storyboard?.instantiateViewController(withIdentifier: "MessageFilterVC") as? MessageFilterVC else{
            return
        }
        
        if(IBlblOffice.isHidden){
            // 27-3 Carer
            messageFiltervc.defaultSelectedRoom = lastSelectedRoomName ?? defaultSelectedPrivateRoomName
            messageFiltervc.strRoomType = RoomType.Client.rawValue
            
        }else{
            messageFiltervc.defaultSelectedRoom = lastSelectedRoomName ?? defaultSelectedPublicRoomName
            messageFiltervc.strRoomType = RoomType.General.rawValue
        }
        
        messageFiltervc.completionHandler = { (chatEngineRoomId,chatRoomName) in
            
            if let roomId = chatEngineRoomId{
                
                if(self.IBlblOffice.isHidden){
                    MessageVC.chatPrivateRoomVC.strRoomId = roomId
                    self.defaultSelectedPrivateRoomId = roomId
                    self.defaultSelectedPrivateRoomName = chatRoomName
                    MessageVC.chatPrivateRoomVC.tempDBQuery(roomId : roomId)
                }else{
                    MessageVC.chatGeneralVC.strRoomId = roomId
                    self.defaultSelectedPublicRoomId = roomId
                    self.defaultSelectedPublicRoomName = chatRoomName
                    MessageVC.chatGeneralVC.tempDBQuery(roomId : roomId)
                }
                
                MessageVC.lastSelectedRoomId = roomId
                self.updateMessageMarkAsAReadCount(roomId: roomId)
            }
            
            self.lastSelectedRoomName = chatRoomName
            self.setSelectedRoomNameOnVC(strRoomName: chatRoomName)
        }
        
        messageFiltervc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(messageFiltervc, animated: false, completion: {
        })
    }
}

// MARK:- Scroll View Delegate
extension MessageVC : UIScrollViewDelegate{
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        dismissKeyboardIfItIsAlreadyOpened()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if currentPage == 1{
            setupDefaultPublicRoom()
        }
        else{
            setDefaultPrivateRoom()
        }
    }
    
}

// MARK:- Client Selection

//extension MessageVC : ClientSelectDelegate{
//
//    func didTappedOnLogout() {
//        removeRealmNotificationForChatAndOffice()
//    }
//
//    func clientSelect(obj: ClientInformationModal) {
//
//        if let selectedUserInformation = DBManager.getClientInfo(userId: obj.client_id){
//
//            setSelctedClientInformationForChatMessage(chatEngineRoomId: selectedUserInformation.chatengine_room_id,
//                                                      chatRoomName: selectedUserInformation.room_name)
//        }
//    }
//
//    func setSelctedClientInformationForChatMessage(chatEngineRoomId : String?,chatRoomName : String?){
//
//        // Here we need to setup the selected client information.
//
//        if let roomId = chatEngineRoomId{
//            setSelectedRoomInformation(roomId: roomId, chatRoomName: chatRoomName)
//        }else{
//
//            let index = arrOfPrivateRooms.filter { return $0.room_name ==  "Direct Message" }
//            setSelectedRoomInformation(roomId: index.first?.chatengine_room_id, chatRoomName:index.first?.room_name )
//        }
//    }
//
//    func setSelectedRoomInformation(roomId : String?,chatRoomName : String?){
//
//        lastSelectedRoomName = nil
//        setSelectedRoomNameOnVC(strRoomName:chatRoomName)
//      //  MessageVC.chatPrivateRoomVC.strRoomId = roomId ?? ""
//
//        defaultSelectedPrivateRoomId = roomId
//        defaultSelectedPrivateRoomName = chatRoomName
//
//        updateMessageMarkAsAReadCount(roomId: roomId ?? "")
//
//        MessageVC.lastSelectedRoomId = roomId
//
//        IBlblChat.isHidden = false
//        IBlblOffice.isHidden = true
//
//        dismissKeyboardIfItIsAlreadyOpened()
//        IBscrollview.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
//    }
//}

// MARK:- add message realm notification

extension MessageVC{
    
    func updateUnreadMessageCountForTabbar(){
        
        ChatDAO._sharedInstance.addMessageQueryRealmNotification()
        
        // arrofRooms contains whole subscribed room id of logged in user
        addUnreadMessageCountForTabbar(arrOfUserInformation: (arrOfPrivateRooms + arrOfPublicRooms) ) { (unreadChatMessageCount) in
            
            guard let tabbar = self.tabBarController?.tabBar.items? [0] else { return }
            
            if(unreadChatMessageCount == "0"){
                tabbar.badgeValue = nil
            }else{
                tabbar.badgeValue = unreadChatMessageCount
            }
        }
        
    }
    
    func updateUnreadMessageCountByCategory(){
        
        // Get the last selected room id and this method will call in view will appear so read the messages once room appears.
        
        if(self.IBlblOffice.isHidden){
            MessageVC.lastSelectedRoomId = defaultSelectedPrivateRoomId
        }else{
            MessageVC.lastSelectedRoomId = defaultSelectedPublicRoomId
        }
        
        updateMessageMarkAsAReadCount(roomId: MessageVC.lastSelectedRoomId ?? "")
        
        addUnreadMessageCountForChat(arrOfUserInformation: arrOfPrivateRooms) { (unreadChatMessageCount) in
            
            if(unreadChatMessageCount == "0"){
                self.IBbtnChat.setTitle("Chat", for: .normal)
            }else{
                self.IBbtnChat.setTitle("Chat(\(unreadChatMessageCount))", for: .normal)
            }
        }
        
        addUnreadMessageCountForOffice(arrOfUserInformation: arrOfPublicRooms) { (unreadChatMessageCount) in
            
//            if(MessageVC.chatPrivateRoomVC.dataController.data.count == 0 ){
//                MessageVC.chatPrivateRoomVC.strRoomId = self.defaultSelectedPrivateRoomId ?? ""
//            }
            
            if(unreadChatMessageCount == "0"){
                self.IBbtnOffice.setTitle("Office", for: .normal)
            }else{
                self.IBbtnOffice.setTitle("Office(\(unreadChatMessageCount))", for: .normal)
            }
        }
    }
    
}

// MARK:- remove realm notification

extension MessageVC{
    
    func removeRealmNotificationForChatAndOffice(){
        
        MessageVC.lastSelectedRoomId = nil
        
//        unreadTotalMessageCountByChat.invalidate()
//        unreadTotalMessageCountByOffice.invalidate()
    }
    
    static func removeRealmNotificationForTabbar(){
        
        // Call this method only when user is getting logged out not everytime
        
        ChatDAO._sharedInstance.messagesToken.invalidate()
        
//        if let _ = MessageVC.chatGeneralVC.subscription?.isValid(){
//            MessageVC.chatGeneralVC.messagesToken.invalidate()
//        }
//
//        if let _ = MessageVC.chatPrivateRoomVC.subscription?.isValid(){
//            MessageVC.chatPrivateRoomVC.messagesToken.invalidate()
//        }
//
//        MessageVC.unreadTotalMessageCountByCategoryToken.invalidate()
    }
    
}

// MARK:- Unread message count realm notification

extension MessageVC{
    
    func addUnreadMessageCountForOffice(arrOfUserInformation : [UserInformarion],unreadMessageCallBackHandler:@escaping successCallback){
        
   //     guard let realm = Realm.shared else { return }
        
        let predicate = NSPredicate(format: "rid IN %@ AND isRead == 0",arrOfUserInformation.compactMap { (obj) -> String? in
            return obj.chatengine_room_id
        })
        
//        let messageQuery = realm.objects(Message.self).filter(predicate)
//
//        unreadTotalMessageCountByOffice = messageQuery.observe{ changes in
//
//            switch changes {
//
//            case .initial :
//
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//
//            case .update(_, _, _, _) :
//
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//
//            default :
//                print("return")
//            }
//        }
    }
    
    func addUnreadMessageCountForChat(arrOfUserInformation : [UserInformarion],unreadMessageCallBackHandler:@escaping successCallback){
        
   //     guard let realm = Realm.shared else { return }
        
        let predicate = NSPredicate(format: "rid IN %@ AND isRead == 0",arrOfUserInformation.compactMap { (obj) -> String? in
            return obj.chatengine_room_id
        })
        
//        let messageQuery = realm.objects(Message.self).filter(predicate)
//
//        unreadTotalMessageCountByChat = messageQuery.observe{ changes in
//
//            switch changes {
//
//            case .initial :
//
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//
//            case .update(_, _, _, _) :
//
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//
//            default :
//                print("return")
//            }
//        }
    }
    
    func addUnreadMessageCountForTabbar(arrOfUserInformation : [UserInformarion],unreadMessageCallBackHandler:@escaping successCallback){
        
    //    guard let realm = Realm.shared else { return }
        
        let predicate = NSPredicate(format: "rid IN %@ AND isRead == 0",arrOfUserInformation.compactMap { (obj) -> String? in
            return obj.chatengine_room_id
        })
        
     //   let messageQuery = realm.objects(Message.self).filter(predicate)
        
//        MessageVC.unreadTotalMessageCountByCategoryToken = messageQuery.observe{ changes in
//            
//            switch changes {
//                
//            case .initial :
//                
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//                
//            case .update(_, _, _, _) :
//                
//                unreadMessageCallBackHandler("\(messageQuery.count)")
//                
//            default :
//                print("return")
//            }
//        }
    }
}

// MARK : UITabBarControllerDelegate Methods

extension MessageVC : UITabBarControllerDelegate{
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex != 0 {
            
            // Set default selected client
            configureDefaultRoomForChat()
            setSelectedRoomNameOnVC(strRoomName:defaultSelectedPrivateRoomName)
            lastSelectedRoomName = defaultSelectedPrivateRoomName
            IBlblChat.isHidden = false
            IBlblOffice.isHidden = true
            IBscrollview.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
        }
    }
}


//
//  MessageFilterVC.swift
//  thecareportal
//
//  Created by Jayesh on 03/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import RealmSwift


class MessageFilterVC: UIViewController {
 
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var heightConstant : NSLayoutConstraint!

    let currentTheme = ThemeManager.shared.currentTheme()
    
    lazy var arrOfRooms : [UserInformarion] = []
    lazy var defaultSelectedRoom = String()
    var completionHandler : ((String?,String?)->())?
    var strRoomType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.       
        getRoomNamesByRoomTypes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRoomNamesByRoomTypes(){
        // 27-3 Carer
        if(strRoomType == RoomType.Client.rawValue){
            
//            if let carerRooms = DBManager.getRoomId(userId: SharedManager.sharedInstance.userProfile.user_id, roomType: RoomType.Carer.rawValue){
//                
//                for room in carerRooms.enumerated(){
//                        room.element.room_name = "Direct Message"
//                        arrOfRooms.append(room.element)
//                }
//            }
            // 27-3 Carer

            if let privateRooms = DBManager.getRoomId(userId: SharedManager.sharedInstance.userProfile.user_id, roomType: RoomType.Client.rawValue){
                
                for room in privateRooms.enumerated(){
                    arrOfRooms.append(room.element)
                }
            }
            
        }else{
            
            if let publicRooms = DBManager.getRoomId(userId: SharedManager.sharedInstance.userProfile.user_id, roomType: strRoomType){
                arrOfRooms = publicRooms
            }
        }
        
        fetchUnreadMessageCountData()
    }
    
    func fetchUnreadMessageCountData(){
        
        guard let realm = Realm.shared else { return }
        
        for room in arrOfRooms.enumerated(){
            
            if let roomId = room.element.chatengine_room_id {
                room.element.unread_message_count = "\(realm.objects(Message.self).filter("rid == '\(roomId)' AND isRead == 0").count)"
            }
        }
        
        
        addTileOnview(arrOutcome: arrOfRooms)
    }
    
    func addTileOnview(arrOutcome : [UserInformarion]){

//        var x : CGFloat = 10
//        var y : CGFloat = 15
//        for (index,obj) in arrOutcome.enumerated(){
//            let title = obj.room_name ?? ""
//            let width = title.getWidthofString(font: UIFont(name: "Lato-Regular", size: 14.0)!) + 5
//            if x + width >= (self.view.frame.size.width - 40){
//                x = 10
//                y = y + 30
//            }
//            let tileview = designView(title: title, unreadMessageCount: obj.unread_message_count ?? "", x: x, y: y)
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width: tileview.frame.size.width, height: tileview.frame.size.height))
//            button.addTarget(self, action: #selector(CarePlanVisitCell.onclickTile(_:)), for: UIControl.Event.touchUpInside)
//            button.tag = index
//            button.accessibilityLabel = "ChatRoomMessageTabButton"
//            
//            if(defaultSelectedRoom == obj.room_name){
//                tileview.backgroundColor = currentTheme.themeColor
//            }else{
//                tileview.backgroundColor = currentTheme.tileBackgroundColor
//            }
//            
//            tileview.layer.cornerRadius = tileview.frame.size.height / 2
////            tileview.layer.borderColor = UIColor.lightGray.cgColor
////            tileview.layer.borderWidth = 1.0
//            tileview.clipsToBounds = true
//            tileview.layer.masksToBounds = true
//            tileview.addSubview(button)
//            mainView.addSubview(tileview)
//            x = x + tileview.frame.size.width + 5
//        }
//        heightConstant.constant = y + 40
    }
    
    func designView(title : String,unreadMessageCount : String,x : CGFloat,y : CGFloat) -> UIView{
        let view = UIView()
        let label = UILabel()
        label.text = title
        label.font = UIFont.CarePortalRegular(size: 14.0)
        label.textColor = currentTheme.tileFontColor
        label.frame = CGRect(x: 5, y: 0, width: label.intrinsicContentSize.width + 2, height: 25)
        view.addSubview(label)
        let roundview = UIView(frame: CGRect(x: label.frame.origin.x + label.frame.size.width,y:label.center.y - 1,width:5, height:5))
        roundview.backgroundColor = UIColor.black
        roundview.layer.cornerRadius = roundview.frame.size.height / 2
        view.addSubview(roundview)
        let lblCount = UILabel()
        lblCount.text = unreadMessageCount
        lblCount.font = UIFont.CarePortalRegular(size: 14.0)
        lblCount.textColor = currentTheme.tileFontColor
        lblCount.frame = CGRect(x: roundview.frame.origin.x + roundview.frame.size.width + 2, y: 0, width: lblCount.intrinsicContentSize.width + 2, height: 25)
        view.addSubview(lblCount)
        view.frame = CGRect(x: x, y: y, width: lblCount.frame.origin.x + lblCount.frame.width + 5, height: 25)
        return view
    }
}

// MARK:- IBaction Methods
extension MessageFilterVC {
    
    @objc func onclickTile(_ sender : UIButton){
        completionHandler?(arrOfRooms[sender.tag].chatengine_room_id,arrOfRooms[sender.tag].room_name)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onclickTap(_ sender : UITapGestureRecognizer){
        self.dismiss(animated: false, completion: nil)
    }
}

//
//  MessageSenderCell.swift
//  thecareprtal
//
//  Created by Jayesh on 29/08/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import UIKit

class MessageSenderCell: UITableViewCell {
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    func configureCell(dictData : NSDictionary)
    {
        self.lblMessage.text = dictData[kMessage] as? String
        self.lblMessage.font = defaultFont
        self.lblDate.text = UtilityClass.convertToTimeFormatter(dateToConvert:(dictData[kDate] as? String)! )
        self.lblDate.font = defaultFont
        
        self.lblMessage.isUserInteractionEnabled = false
        self.lblMessage.numberOfLines = 0
        self.lblMessage.lineBreakMode = .byWordWrapping
        
        
        //DispatchQueue.main.async {
        let labelSize = UtilityClass.rectForText(text: (self.lblMessage.text! as NSString) as String, font:defaultFont, maxSize: CGSize(width: Int(kCell_Width), height: 9999))
        
        print("width of the Label \(labelSize.width) height of the Label \(labelSize.height)")
        
        //            if labelSize.width > CGFloat(UtilityClass.getScreenWidth(kCell_Width))
        //            {
        //                labelSize.width = CGFloat(UtilityClass.getScreenWidth(kCell_Width))
        //            }
        
        /// Date Label Frame
        var cgDateFrame = self.lblDate.frame
        cgDateFrame.origin.y = labelSize.height + CGFloat(kCell_Ygap)
        cgDateFrame.size.height = CGFloat(kCell_DateHight)
        self.lblDate.frame = cgDateFrame
        
        var height = labelSize.height
        height += 20
        height += 15
        /// View CHAT Frame
        var cgChatFrame = self.viewChat.frame
        cgChatFrame.origin.y = 0
        cgChatFrame.origin.x = CGFloat(UtilityClass.getScreenWidth(320) - Float(labelSize.width) - Float(kCell_XGap) - Float(kCell_SpaceOfBothSide))
        cgChatFrame.size.width = CGFloat(kCell_SpaceOfBothSide) + labelSize.width
        cgChatFrame.size.height = height
        self.viewChat.frame = cgChatFrame
        /// Message Label Frame
        var cgFrame = self.lblMessage.frame
        cgFrame.origin.y = CGFloat(kCell_Ygap)
        cgFrame.origin.x = CGFloat(UtilityClass.getScreenWidth(10))
        cgFrame.size.width = labelSize.width
        cgFrame.size.height = labelSize.height
        self.lblMessage.frame = cgFrame
        //cell.lblMessage.backgroundColor = UIColor.red
        self.viewChat.layer.cornerRadius = 7
        self.viewChat.clipsToBounds = true
        self.viewChat.backgroundColor = UIColor.lightGray
        // }
    }
    
}

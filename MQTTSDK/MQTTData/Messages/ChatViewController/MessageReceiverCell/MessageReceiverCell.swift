

import UIKit

class MessageReceiverCell: UITableViewCell {
    
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
        
        let labelSize = UtilityClass.rectForText(text: (self.lblMessage.text! as NSString) as String, font:defaultFont, maxSize: CGSize(width: Int(kCell_Width), height: 9999))
        
        print("width of the Label \(labelSize.width) height of the Label \(labelSize.height)")
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
        cgChatFrame.origin.x = CGFloat(kCell_XGap)
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
        
        self.viewChat.layer.cornerRadius = 6.0
        self.viewChat.clipsToBounds = true
        self.viewChat.backgroundColor = UIColor.lightGray
    }
}

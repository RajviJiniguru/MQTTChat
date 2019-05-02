//
//  SenderImageCell.swift
//  MqttChatDemo
//
//  Created by Jayesh on 13/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import UIKit

class SenderImageCell: UITableViewCell {
    
    let currentTheme = ThemeManager.shared.currentTheme()

    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var viewChat: UIView!

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
        self.lblDate.text = UtilityClass.convertToTimeFormatter(dateToConvert:(dictData[kDate] as? String)! )
        self.lblDate.font = defaultFont
        
       // self.lblNameTitle.text =  dictData[kName] as? String
     //   self.lblNameTitle.font = defaultFont
        
    //    if dictData.object(forKey: "is_export") as! String == "0"
        //{
            let imagePath = UtilityClass.buildFullPath(forFileName:(dictData[kMessage] as? String)! , inDirectory: AppDirectories.ImageCollection)
            
            if self.imgCell.image == nil
            {
                let image = UIImage(contentsOfFile: imagePath.path)
                self.imgCell.image = image
            }
   //     }
        
//        self.viewChat.layer.cornerRadius = 7
//        self.viewChat.clipsToBounds = true
//        self.viewChat.backgroundColor = currentTheme.MsgBackgroundColor
 
//        else
//        {
//            Alamofire.request((dictData[kMessage] as? String)!).responseImage { response in
//                debugPrint(response)
//                debugPrint(response.result)
//                
//                if let image = response.result.value {
//                    print("image downloaded: \(image)")
//                    self.imgCell.image = image
//                }
//            }
//        }
        
        
        
       
        //self.imgCell.image = dictData.
    }
    
}

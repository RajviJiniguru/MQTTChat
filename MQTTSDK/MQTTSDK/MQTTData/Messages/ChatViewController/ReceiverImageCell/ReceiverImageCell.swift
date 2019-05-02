//
//  ReceiverImageCell.swift
//  MqttChatDemo
//
//  Created by Jayesh on 13/09/18.
//  Copyright © 2018 Hitesh. All rights reserved.
//

import UIKit

class ReceiverImageCell: UITableViewCell {
    
    let currentTheme = ThemeManager.shared.currentTheme()

    @IBOutlet weak var imgcell: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewChat: UIView! 
    @IBOutlet weak var lblNameTitle: UILabel!

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
        
//        self.lblNameTitle.text =  dictData[kName] as? String
//        self.lblNameTitle.font = defaultFont
        
        if let imgUrl = URL(string : (dictData[kMessage] as? String)!)
        {
            print("imageUrlString== \(imgUrl)")
            
            let url = URL(string: (dictData[kMessage] as? String)!)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageView?.image = UIImage(data: data!)
        }
        
        
//        
//        /// Name Title Label Frame
//        var cgFrame1 = self.lblNameTitle.frame
//        cgFrame1.origin.x = CGFloat(UtilityClass.getScreenWidth(10))
//        self.lblNameTitle.frame = cgFrame1
        
       
//        Alamofire.request((dictData[kMessage] as? String)!).responseImage { response in
//            debugPrint(response)
//       //     print(response.request)
//         //   print(response.response)
//            debugPrint(response.result)
//            
//            if let image = response.result.value {
//                print("image downloaded: \(image)")
//                self.imgCell.image = image
//            }
//        }
        
        
//        let imagePath = UtilityClass.buildFullPath(forFileName:(dictData[kMessage] as? String)! , inDirectory: AppDirectories.ImageCollection)
//
//        if self.imgCell.image == nil
//        {
//            let image = UIImage(contentsOfFile: imagePath.path)
//            self.imgCell.image = image
//        }
    }
    
   
    
    
}

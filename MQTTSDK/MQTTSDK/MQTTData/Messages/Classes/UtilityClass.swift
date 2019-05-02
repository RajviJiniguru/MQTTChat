//
//  UtilityClass.swift
//  thecareprtal
//
//  Created by Jayesh on 30/08/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import UIKit

enum AppDirectories : String
{
    case Documents = "Documents"
    case ImageCollection = "ImageCollection"
    
}

 let defaultFontSize = CGFloat(15)
 let defaultFont = UIFont.systemFont(ofSize: defaultFontSize)


class UtilityClass: NSObject
{

    class func rectForText(text: String, font: UIFont, maxSize: CGSize) -> CGSize {
        let attrString = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font:font])
        let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
    }
    
    class func getScreenWidth(_ size : Float) -> Float
    {
        let sizeByWidth = UIScreen.main.bounds.width/320
        let finalSize  = (size * Float(sizeByWidth))
        return finalSize
    }
    
   class func convertToTimeFormatter(dateToConvert:String) -> String {
    
    let formatter = DateFormatter()
  
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let yourDate = formatter.date(from: dateToConvert)

    formatter.dateFormat = "hh:mm a"
 
    let myStringafd = formatter.string(from: yourDate!)
    
    print(myStringafd)
    return myStringafd
    
    }
    
    class func documentsDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    class func ImageDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.ImageCollection.rawValue)
    }
    
    class func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
    {
        return UtilityClass.getURL(for: directory).appendingPathComponent(name)
    }
    
    class func getURL(for directory: AppDirectories) -> URL
    {
        switch directory
        {
        case .Documents:
            return UtilityClass.documentsDirectoryURL()
        case .ImageCollection:
            return UtilityClass.ImageDirectoryURL()
        }
      }
    
}

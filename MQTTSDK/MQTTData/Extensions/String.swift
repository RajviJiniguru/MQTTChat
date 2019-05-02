//
//  String.swift
//  thecareportal
//
//  Created by Jayesh on 25/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import Foundation

func localized(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

extension String{
    
    func getWidthofString(font : UIFont) -> CGFloat{
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes)
        return size.width
    }
    
    func getConvertDateString(currentdateformatter : String ,convdateformatter : String) -> String{
        //Sunday,July 16 2017
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = currentdateformatter
        let date = dateformatter.date(from: self)
        dateformatter.dateFormat = convdateformatter
        return dateformatter.string(from:date!)
    }
    
    static func random(_ length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return randomString
    }
    
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
//    func sha256() -> String {
//        if let stringData = self.data(using: String.Encoding.utf8) {
//            return hexStringFromData(input: digest(input: stringData as NSData))
//        }
//        
//        return ""
//    }
    
//    private func digest(input: NSData) -> NSData {
//        let digestLength = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
//        var hash = [UInt8](repeating: 0, count: digestLength)
//        CC_SHA256(input.bytes, UInt32(input.length), &hash)
//        return NSData(bytes: hash, length: digestLength)
//    }

    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }
        
        return hexString
    }
    
    func ranges(of string: String) -> [Range<Index>] {
        var ranges = [Range<Index>]()
        
        let pCount = string.count
        let strCount = self.count
        
        if strCount < pCount { return [] }
        
        for i in 0...(strCount-pCount) {
            
            let from = index(self.startIndex, offsetBy: i)
            
            if let to = index(from, offsetBy: pCount, limitedBy: self.endIndex) {
                
                if string == self[from..<to] {
                    ranges.append(from..<to)
                }
            }
        }
        
        return ranges
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

    func getDateFromString(dateFormatter : String) -> Date{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormatter
        return dateformatter.date(from: self)!

    }
    func htmlAttributedString(color : UIColor,fontsize : String) -> NSAttributedString? {
        
        let inputText = "\(self)<style>body { font-family: 'Lato-Regular'; font-size:fontsize; \(color.hexDescription())}</style>"
      
        guard let data = inputText.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return nil }
        
        guard let html = try? NSMutableAttributedString (
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }
        return html
    }
}

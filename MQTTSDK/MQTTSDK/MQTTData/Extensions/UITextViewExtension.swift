//
//  UITextViewExtension.swift
//  Rocket.Chat
//
//  Created by Anil Kukadeja on 08/06/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension UITextView{
    
    func setPlaceholder(placeHolderText : String) {
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeHolderText
        placeholderLabel.font = UIFont.init(name: "Lato-Regular", size: 12.0)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 100
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! * 0.6)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    
    func hidePlaceHolderIfNeeded() {
        let placeholderLabel = self.viewWithTag(100) as? UILabel
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
}

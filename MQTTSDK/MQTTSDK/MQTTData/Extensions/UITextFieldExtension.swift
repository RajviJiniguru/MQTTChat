//
//  UITextFieldExtension.swift
//  thecareprtal
//
//  Created by Anil Kukadeja on 03/05/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: "Placeholder Text", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }
    
    func setPlaceHolderColor(placeHolderText : String,color : UIColor){
        self.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
}

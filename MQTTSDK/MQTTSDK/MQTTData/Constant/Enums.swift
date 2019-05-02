//
//  Enums.swift
//  Rocket.Chat
//
//  Created by JiniGuruiOS on 6/22/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

enum Lato : String {
    
    case  black = "Lato-Black"
    case  boldItalic = "Lato-BoldItalic"
    case  bold = "Lato-Bold"
    case  blackItalic = "Lato-BlackItalic"
    case  italic = "Lato-Italic"
    case  hairlineItalic = "Lato-HairlineItalic"
    case  regular = "Lato-Regular"
    case  hairline = "Lato-Hairline"
    case  lightItalic = "Lato-LightItalic"
    case  light = "Lato-Light"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}


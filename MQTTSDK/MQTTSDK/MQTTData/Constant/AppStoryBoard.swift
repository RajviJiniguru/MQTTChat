//
//  AppStoryBoard.swift
//  Rocket.Chat
//
//  Created by Anil Kukadeja on 08/05/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

// swiftlint:disable <vertical_whitespace> ,<vertical_parameter_alignment>,<trailing_whitespace>,<trailing_newline>,<trailing_semicolon>]

enum AppStoryboard:String {
    
    case Authentication
    case Tabbar
    case Messages
    case Schedule
    case CarePlan
    case CareNote
    case Menu
    case More
    
    var instance:UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
}

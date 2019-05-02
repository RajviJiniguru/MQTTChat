//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {
    
    static let defaultFontSize = CGFloat(15)

    static let defaultFontColor = UIColor.white
    static let systemFontColor = UIColor.white

    static let defaultFont = UIFont.systemFont(ofSize: defaultFontSize)
    static let italicFont = UIFont.italicSystemFont(ofSize: defaultFontSize)
    static let boldFont = UIFont.systemFont(ofSize: defaultFontSize)
    
    static let latoRegular = UIFont.latoRegular(size: defaultFontSize)
    static let latoBold = UIFont.latoBold(size: defaultFontSize)
    

}

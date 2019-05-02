//
//  UIButton.swift
//  thecareprtal
//
//  Created by Anil Kukadeja on 04/05/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import Foundation

extension UIButton {
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

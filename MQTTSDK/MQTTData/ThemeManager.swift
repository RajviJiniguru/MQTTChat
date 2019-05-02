//
//  ThemeManager.swift
//  thecareprtal
//
//  Created by Anil Kukadeja on 03/05/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import UIKit

import Foundation

enum Theme: Int {
    
    case theme1, theme2
    
    // MARK: GENERAL COLORS
    var MsgBackgroundColor: UIColor {
       
            return UIColor(red: 0.0 / 255.0, green: 120.0/255.0, blue: 183.0 / 255.0, alpha: 1.0)
    }
    
    var themeColor : UIColor {
        switch self {
        case .theme1:
            return  UIColor(red: 0/255.0, green: 116.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 37.0/255.0, green: 175.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        }
    }
    
    var borderColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 203.0 / 255.0, green: 203.0/255.0, blue: 182.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 203.0 / 255.0, green: 203.0/255.0, blue: 182.0 / 255.0, alpha: 1.0)
        }
    }
    
    var tileBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 199.0 / 255.0, green: 198.0/255.0, blue: 203.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 199.0 / 255.0, green: 198.0/255.0, blue: 203.0 / 255.0, alpha: 1.0)
        }
    }
    
    var tileFontColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
   
    var barStyle: UIBarStyle {
        switch self {
        case .theme1:
            return .default
        case .theme2:
            return .black
        }
    }
    
    var prefferedBarStyle : UIStatusBarStyle{
        
        switch self {
        case .theme1:
            return .lightContent
        case .theme2:
            return .default
        }
    }
    
    var navigationBackgroundImage: UIImage? {
        return self == .theme1 ? UIImage(named: "navBackground") : nil
    }
    
    var tabBarBackgroundImage: UIImage? {
        return self == .theme1 ? UIImage(named: "tabBarBackground") : nil
    }
    
    var buttonBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
    
    var textFieldTextColor : UIColor{
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
    
    var textFieldBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor(red: 0/255.0, green: 120.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 37.0/255.0, green: 175.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var subtitleTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
    
    var commonColor : UIColor{
        switch self{
            case .theme1:
                return UIColor.white
            case .theme2:
                return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
            }
    }
    
    // MARK: MODULE SPECIFIC COLORS
    
    var addNoteBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 62.0 / 255.0, green: 62.0/255.0, blue: 62.0 / 255.0, alpha: 1.0)
        }
    }
    
    var completeStatusBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 11.0 / 255.0, green: 143.0/255.0, blue: 59.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 11.0 / 255.0, green: 143.0/255.0, blue: 59.0 / 255.0, alpha: 1.0)
        }
    }
    
    var inCompleteStatusBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 197.0 / 255.0, green: 23.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 197.0 / 255.0, green: 23.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        }
    }
    
    var calendarDateColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 146.0 / 255.0, green: 146.0/255.0, blue: 146.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 146.0 / 255.0, green: 146.0/255.0, blue: 146.0 / 255.0, alpha: 1.0)
        }
    }
    
    var slideAddnoteBackgroundColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 197.0 / 255.0, green: 166.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 197.0 / 255.0, green: 166.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        }
    }
    
    var pendingTaskColor : UIColor{
        switch self {
        case .theme1:
            return UIColor(red: 197.0 / 255.0, green: 166.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 197.0 / 255.0, green: 166.0/255.0, blue: 23.0 / 255.0, alpha: 1.0)
        }
    }
    
    var menuSelectionColor : UIColor {
        switch self {
        case .theme1:
            return  UIColor(red: 0.0/255.0, green: 93.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 37.0/255.0, green: 175.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        }
    }
    
    var switchOnTintColor : UIColor {
        switch self {
        case .theme1:
            return  UIColor(red: 62.0/255.0, green: 62.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        case .theme2:
            return UIColor(red: 11.0/255.0, green: 144.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        }
    }
    
}

// Enum declaration
let SelectedThemeKey = "SelectedTheme"

// This will let you use a theme in the app.
class ThemeManager {
    
    static let shared = ThemeManager()
    
    // ThemeManager
    func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .theme2
        }
    }
    
    func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        // You get your current (selected) theme and apply the main color to the tintColor property of your application’s window.
//        let sharedApplication = UIApplication.shared
//        sharedApplication.delegate?.window??.tintColor = theme.themeColor
//
//        UINavigationBar.appearance().barStyle = theme.barStyle
//        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
//        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")
        
//        UITabBar.appearance().barStyle = theme.barStyle
//        UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage
        
//        let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
//        let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
//        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator
//
//        let controlBackground = UIImage(named: "controlBackground")?.withRenderingMode(.alwaysTemplate)
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
//        let controlSelectedBackground = UIImage(named: "controlSelectedBackground")?
//            .withRenderingMode(.alwaysTemplate)
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        
//        UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
//        UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)
        
//        UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
//        UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
//        UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
//        UIStepper.appearance().setDecrementImage(UIImage(named: "fewerPaws"), for: .normal)
//        UIStepper.appearance().setIncrementImage(UIImage(named: "morePaws"), for: .normal)
//        
//        UISlider.appearance().setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
//        UISlider.appearance().setMaximumTrackImage(UIImage(named: "maximumTrack")?
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
//        UISlider.appearance().setMinimumTrackImage(UIImage(named: "minimumTrack")?
//            .withRenderingMode(.alwaysTemplate)
//            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)
    }
}

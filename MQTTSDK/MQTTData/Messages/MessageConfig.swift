//
//  MessageConfig.swift
//  MQTTSDK
//
//  Created by Parth Adroja on 30/04/19.
//  Copyright © 2019 Rajvi. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import SlackTextViewController

extension UIApplication{
    
    /// JiniGuru - Sandip: Get the top most view controller from the base view controller; default param is UIWindow's rootViewController
    public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
}

public class MessageConfig{

    public class func chatRedirect()
    {

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatMessageVC.self,SLKTextViewController.self]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatMessageVC.self,SLKTextViewController.self]
        
        
        let bundle = Bundle(for: ChatMessageVC.classForCoder())
        let cardStreamPayment = ChatMessageVC.init(nibName: "ChatMessageVC", bundle:bundle)

        
        UIApplication.topViewController()?.navigationController?.pushViewController(cardStreamPayment, animated: true)
        
    }
}


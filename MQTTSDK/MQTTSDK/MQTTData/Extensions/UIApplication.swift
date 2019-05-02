//
//  UIApplication.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 01/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit

extension UIApplication{
    
    func applicationVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String
    }
    
    func applicationBuild() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    func versionBuild() -> String? {
        let version = self.applicationVersion()
        let build = self.applicationBuild()
        
        return "v\(version ?? "")(\(build ?? ""))"
    }
}

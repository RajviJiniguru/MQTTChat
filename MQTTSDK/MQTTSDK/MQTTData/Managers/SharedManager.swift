//
//  SharedManager.swift
//  thecareportal
//
//  Created by Jayesh on 08/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import SwiftyJSON
class SharedManager {
    
    // Shared instance
    static let sharedInstance = SharedManager()
    
    // For storelogin user info
    var userProfile = UserInformarion(json: JSON.null)
    
    // For Store Select Client
    var clientProfile : ClientInformationModal?
    var Clients : [ClientInformationModal] = []
}

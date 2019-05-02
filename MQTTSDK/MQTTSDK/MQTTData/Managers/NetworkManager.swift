//
//  NetworkManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Reachability

//class NetworkManager {
//
//    static let shared = NetworkManager()
//    var reachability: Reachability?
//
//    static var isConnected: Bool {
//        if self.shared.reachability != nil {
//            self.shared.reachability = Reachability()
//        }
//
//        return self.shared.reachability?.connection != .none
//    }
//
//    func start() {
//        reachability = Reachability()
//    }
//
//}



//======
protocol ReachabilityDelegate: class
{
    func reachabilityStatusChangeHandler(_ reachability:Reachability)
}

class NetworkManager: NSObject
{
    var reachability: Reachability!
    var delegate:ReachabilityDelegate?
    var isNetWorkAvailable : Bool = false
    
    
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    static let shared = NetworkManager()
    
    static var isConnected: Bool {
        if self.shared.reachability != nil {
            self.shared.reachability = Reachability()
        }
        
        return self.shared.reachability?.connection != .none
    }
    
    func start() {
        reachability = Reachability()
    }

    
    
    override init() {
        super.init()
        
        reachability = Reachability()!
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        
        let reachability = notification.object as! Reachability
        
        self.delegate?.reachabilityStatusChangeHandler(reachability)
        
        switch reachability.connection
        {
        case .wifi:
            NetworkManager.sharedInstance.isNetWorkAvailable = true
        case .cellular:
            NetworkManager.sharedInstance.isNetWorkAvailable = true
            
        case .none:
            NetworkManager.sharedInstance.isNetWorkAvailable = false
        }
    }
    
    static func stopNotifier() -> Void {
        do {
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}




//
//  AppDelegate.swift
//  thecareportal
//
//  Created by Jayesh on 23/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import RealmSwift
import UserNotifications
import SlackTextViewController
import Reachability
import Firebase
import SwiftLocation
import Crashlytics
import SwiftyJSON
import GRDB

//var dbPool: DatabasePool!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
   // var configuration: CarerConfiguration!
   // var locationRequest : Request!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
    //    configuration  = CarerConfiguration()
        
        // Override point for customization after application launch.
        // enable iq keyboard manager
        
        FirebaseApp.configure()
        
        checkIfApplicationHasLaunchedWithUITests() // checkIfApplicationHasLaunchedWithUITests
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatMessageVC.self,SLKTextViewController.self]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatMessageVC.self,SLKTextViewController.self]
        
        Launcher().prepareToLaunch(with: launchOptions)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        application.registerForRemoteNotifications()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //DBManager.sharedInstance().readDataFromSqlFile(fileName: "main.sql")
        
        if let _ = launchOptions?[UIApplication.LaunchOptionsKey.location] {
            if Helper.getBoolPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN) && Helper.getBoolPREF(UserDefaultsConstant.PREF_LOCATION_TRACKING){
//                locationRequest = Locator.subscribeSignificantLocations(onUpdate: { newLocation in
//
//                    // This block will be executed with the details of the significant location change that triggered the background app launch,
//                    // and will continue to execute for any future significant location change events as well (unless canceled).
//                    self.startUpdatingLocation()
//
//                    DBManager.insertDataIntoLocationTable(location: newLocation.coordinate)
//
//                }, onFail: { (err, lastLocation) in
//                    // Something bad has occurred
//                })
            }
        }
        
      //  checkUserLoggedInAndNavigationFlow()
        configureAppTheme()
        
        //        // Do not comment this line as this is causing network connection lost
        //        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 30
        
        self.copyMasterDatabse()
        try! setupDatabase(application)

        return true
    }
    
    func copyMasterDatabse(){
        if let url = DBManager.sharedInstance().documentDirecotryPath{
            let fileUrl = url.appendingPathComponent(DBManager.sharedInstance().masterDatabaseFileName)
            let fileExist = FileManager.default.fileExists(atPath: fileUrl.path)
            if(!fileExist){
                do{
                    if let pushDataSqlite = Bundle.main.resourceURL?.appendingPathComponent(DBManager.sharedInstance().masterDatabaseFileName).path{
                        try FileManager.default.copyItem(atPath: (pushDataSqlite), toPath: fileUrl.path)
                    }
                }catch{
                    print("\n",error)
                }
            }else{
                print("file exist")
            }
        }
    }
    
    
    private func setupDatabase(_ application: UIApplication) throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let databasePath = documentsPath.appendingPathComponent("master.sqlite")
        dbPool =  try AppDatabase.openDatabase(atPath: databasePath)//try DatabasePool(path: databasePath)
        //try AppDatabase.openDatabase(atPath: databasePath)
        
        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/#memory-management
        dbPool.setupMemoryManagement(in: application)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //        SubscriptionManager.updateUnreadApplicationBadge()
        //
        //        if AuthManager.isAuthenticated() != nil {
        //            SocketManager.disconnect({ (_, _) in })
        //        }
        
        // Chacking for location
        if Helper.getBoolPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN) && Helper.getBoolPREF(UserDefaultsConstant.PREF_LOCATION_TRACKING){
            Locator.subscribeSignificantLocations(onUpdate: { (location) -> (Void) in
                self.startUpdatingLocation()
            }) { (error, last) -> (Void) in
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        //        if AuthManager.isAuthenticated() != nil {
        //
        //            if(!SocketManager.isConnected()){
        //                SocketManager.reconnect()
        //            }
        //
        //        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //        if AuthManager.isAuthenticated() != nil {
        //
        //            if !SocketManager.isConnected() {
        //                ChatDAO._sharedInstance.reconnect()
        //            }
        //        }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        if Helper.getBoolPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN) && Helper.getBoolPREF(UserDefaultsConstant.PREF_LOCATION_TRACKING){
            startUpdatingLocation()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func checkIfApplicationHasLaunchedWithUITests() {
        
        if ProcessInfo.processInfo.arguments.contains("LoginUITests") {
            
            SharedManager.sharedInstance.clientProfile = nil
            SharedManager.sharedInstance.userProfile = UserInformarion(json: JSON.null)
            SharedManager.sharedInstance.Clients.removeAll()
            Helper.delPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN)
            Helper.delPREF(UserDefaultsConstant.PREF_USER_DATA)
        }
    }
    
    // MARK: Remote Notification
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Log.debug("Notification: \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Log.debug("Notification: \(userInfo)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.standard.set(deviceToken.hexString, forKey: PushManager.kDeviceTokenKey)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("Fail to register for notification: \(error)")
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "thecareportal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        if let reachability = note.object as? Reachability{
            
            if reachability.connection != .none  {
                
                if Helper.getBoolPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN){
                    ChatDAO._sharedInstance.reconnect()
                }
                
                //                if reachability.isReachableViaWiFi {
                //                    print("Reachable via WiFi")
                //                } else {
                //                    print("Reachable via Cellular")
                //                }
            } else {
                ChatDAO._sharedInstance.removeCompletionBlocksIfNetworkConnectionGetsLost()
            }
        }
    }
}

extension AppDelegate{
    
//    func checkUserLoggedInAndNavigationFlow(){
//        if Helper.getBoolPREF(UserDefaultsConstant.PREF_IS_USER_LOGGED_IN){
//            guard let loginvc = AppStoryboard.Authentication.instance.instantiateViewController(withIdentifier: String(describing:LoginVC.self)) as? LoginVC else{
//                return
//            }
//
//            // Authentication view controller
//            guard let authVC = AppStoryboard.Authentication.instance.instantiateViewController(withIdentifier: String(describing:FingurePrintVC.self)) as? FingurePrintVC else{
//                return
//            }
//
//            // reveal view controller
//            guard let revealvc = AppStoryboard.Menu.instance.instantiateViewController(withIdentifier: String(describing:SWRevealViewController.self)) as? SWRevealViewController else{
//                return
//            }
//
//            // Navigation view controller
//            guard let navVC = UIApplication.shared.delegate!.window!?.rootViewController as? UINavigationController else{
//                return
//            }
//
//            if (Helper.getBoolPREF(UserDefaultsConstant.PREF_FINGUREPRINT_AUTH) || Helper.getBoolPREF(UserDefaultsConstant.PREF_PIN_AUTH) ){
//                navVC.viewControllers=[loginvc,authVC]
//            }
//            else{
//                if let userInfo = Helper.getDataPREF(UserDefaultsConstant.PREF_USER_DATA){
//                    do{
//                        SharedManager.sharedInstance.userProfile = try JSONDecoder().decode(UserInformarion.self, from: userInfo)
//                        navVC.viewControllers=[loginvc,revealvc]
//                    }
//                    catch (let error){
//                        navVC.viewControllers=[loginvc]
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: NetworkManager.shared.reachability)
//
//        do{
//            try  NetworkManager.shared.reachability?.startNotifier()
//        }catch{
//            print("could not start reachability notifier")
//        }
//    }
    
    func startUpdatingLocation(){
        
//        locationRequest = Locator.subscribePosition(accuracy: .house, onUpdate: { (locationObject) -> (Void) in
//            print("Receieved location object",locationObject)
//            DBManager.insertDataIntoLocationTable(location: locationObject.coordinate)
//
//        }) { (error, lastLocation) -> (Void) in
//            print("Failed with err: \(error)")
//        }
    }
    
    func configureAppTheme(){
        
        #if NewTheme
        ThemeManager.shared.applyTheme(theme: .theme1)
        #else
        ThemeManager.shared.applyTheme(theme: .theme2)
        #endif
        
    }
    
}


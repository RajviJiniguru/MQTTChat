//
//  DBManager.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 02/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB
//import Zip

enum DatabaseType{
    case masterDatabase
    case slaveDatabase
    case partialSyncDatabase
}

class DBManager: NSObject {
    
    static let _sharedInstance = DBManager()
    
    let masterDatabaseFileName = "master.sqlite"
    let slaveDatabaseFileName = "PushData.sqlite"
    let partialSyncDataBaseFileName = "partial"
    
    var masterDatabase : FMDatabase?
    var slaveDatabase : FMDatabase?
    
    class func sharedInstance() -> DBManager {
        return _sharedInstance
    }
    
    var documentDirecotryPath : URL?{
        get{
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            return URL(fileURLWithPath: path)
        }
    }
    
    var emergancyImageDirectryPath : URL?{
        get{
            let path = DBManager.sharedInstance().documentDirecotryPath?.appendingPathComponent("emergency_images")
            return path
        }
    }
    
    func copySlaveDatabse(){
        if let url = DBManager.sharedInstance().documentDirecotryPath{
            let fileUrl = url.appendingPathComponent(DBManager.sharedInstance().slaveDatabaseFileName)
            let fileExist = FileManager.default.fileExists(atPath: fileUrl.path)
            if(!fileExist){
                do{
                    if let pushDataSqlite = Bundle.main.resourceURL?.appendingPathComponent(DBManager.sharedInstance().slaveDatabaseFileName).path{
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
    
    func openMasterDatabase() -> Bool {
      
        if DBManager.sharedInstance().masterDatabase == nil {
            if let fileUrl = DBManager._sharedInstance.documentDirecotryPath?.path{
                if FileManager.default.fileExists(atPath:fileUrl + "/" + DBManager._sharedInstance.masterDatabaseFileName) {
                    DBManager._sharedInstance.masterDatabase = FMDatabase(path: fileUrl + "/" + DBManager._sharedInstance.masterDatabaseFileName)
                }
            }
        }
        
        if let database = DBManager._sharedInstance.masterDatabase{
            if database.open(){
                return true
            }
        }
        
        return false
    }
    
    func openSlaveDatabase() -> Bool {
        if DBManager.sharedInstance().slaveDatabase == nil {
            if let fileUrl = DBManager._sharedInstance.documentDirecotryPath?.path{
                if FileManager.default.fileExists(atPath:fileUrl + "/" + DBManager._sharedInstance.slaveDatabaseFileName) {
                    DBManager._sharedInstance.slaveDatabase = FMDatabase(path: fileUrl + "/" + DBManager._sharedInstance.slaveDatabaseFileName)
                }
            }
        }
        
        if let database = DBManager._sharedInstance.slaveDatabase{
            if database.open(){
                return true
            }
        }
        return false
    }
    
    func getFileNamesAtDocumentDirectoryByExtension(pathExtension : String) -> (arrOfUrls : [URL]?,arrOfFileNames : [String]?){
        
        guard let documentsDirectoryPath = DBManager.sharedInstance().documentDirecotryPath else{
            return (nil,nil)
        }
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectoryPath, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            
            // This will give sqlite3files list in entire directory
            let fileUrls = directoryContents.filter{ $0.pathExtension == pathExtension }
            var fileNames : [String]?
            fileNames = fileUrls.map{ $0.deletingPathExtension().lastPathComponent }
            return (fileUrls,fileNames)
            
        } catch {
            print(error.localizedDescription)
        }
        
        return (nil,nil)
        
    }
    
    func changeFileNameAtDocumentDirectory(fileUrl : URL? , fileName : String?,extensionType : String,newFileName : String){
        
        if let fileName = fileName{
            do {
                
                guard let originPath = DBManager.sharedInstance().documentDirecotryPath?.appendingPathComponent(fileName) else{
                    return
                }
                
                guard let destinationPath = DBManager.sharedInstance().documentDirecotryPath?.appendingPathComponent(newFileName) else{
                    return
                }
                
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
                
                if(extensionType == "sql"){
                    DBManager.sharedInstance().readDataFromSqlFile(fileName: newFileName)
                }else{
                    updateMasterDbAfterPartialSync()
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func generateZipFile(successCompletionHandler:@escaping successCallbackWithData, messageCallBackHandler:@escaping messageCallbackWithData, errorHandler: @escaping errorCallback){
        
        // This method will generate zip file containing database from resource folder.
        
        if DBManager.sharedInstance().openSlaveDatabase(){
            
            if let databaseUrl = DBManager.sharedInstance().slaveDatabase?.databaseURL{
                
                do {
                     DBManager.sharedInstance().insertDataInSlavebaseBeforePartialSync()
                    var fileUrl : URL!
//                    if let imgPath  = DBManager.sharedInstance().emergancyImageDirectryPath{
//                        if FileManager.default.fileExists(atPath: imgPath.path){
//                            fileUrl =  try Zip.quickZipFiles([databaseUrl,imgPath], fileName: assignRandomUUIDName())
//                        }
//                        else{
//                            fileUrl = try Zip.quickZipFiles([databaseUrl], fileName: assignRandomUUIDName()) // Zip
//                        }
//                    }
//                    else{
//                        fileUrl = try Zip.quickZipFiles([databaseUrl], fileName: assignRandomUUIDName()) // Zip
//                    }
                    DBDAO.WSCallPartialSyncDB(fileUrl: fileUrl, parameters: nil,downloadProgress: { (progress) in
                        
                    },successCompletionHandler: { (response) in
                        successCompletionHandler(response)
                    }, messageCallBackHandler: { (msg) in
                        messageCallBackHandler(msg)
                    }, errorHandler: { (error) in
                        errorHandler(error)
                    })
                }
                catch {
                    print("Something went wrong")
                }
                
            }
        }
    }
    
    func assignRandomUUIDName() -> String{
        return "\(UUID().uuidString)"
    }
    
    func deleteFilesAtDocumentDirectory(fileUrl : URL){
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
    }
    
    static func getUserData(){
        
        if DBManager.sharedInstance().openMasterDatabase(){
            
            let query = "Select * from hc_clients"
            
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                
                while results.next() {
                    
                }
            }
            catch {
                print(error.localizedDescription)
            }

            _sharedInstance.masterDatabase?.close()
        }
    }
    
    func getAllTableFromMasterDatabase() -> [String]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query = "select name from sqlite_master where type='table'"
            do {
                let results = try  DBManager.sharedInstance().masterDatabase!.executeQuery(query, values: nil)
                var tablename : [String] = []
                while results.next() {
                  tablename.append(results.string(forColumn: "name") ?? "")
                }
                return tablename
            }
            catch {
                print(error.localizedDescription)
            }
            DBManager.sharedInstance().masterDatabase?.close()
            return nil
        }
        return nil
    }
    
    
    func addDummyDataToClientTaskLogTable(){
        
        if DBManager.sharedInstance().openMasterDatabase(){
            
            if(DBManager.sharedInstance().openSlaveDatabase()){
                
                let attachDatabaseStatement = "ATTACH DATABASE \'\(slaveDatabase!.databaseURL!.path)' AS slave"
              
                if let result = DBManager.sharedInstance().masterDatabase?.executeStatements(attachDatabaseStatement){
                
                    if(result){
                        
                        
                             let masterQuery = "INSERT INTO slave.hc_client_task_log SELECT * FROM main.hc_client_task_log"
                            do {
                               
                                
                                guard let results1 = try DBManager.sharedInstance().masterDatabase?.executeQuery(masterQuery, values: nil)
                                    else{
                                        return
                                }
                                
                                while(results1.next()){
                                    
                                }
                                
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                
                }
                
                DBManager.sharedInstance().slaveDatabase?.close()
            }
        }
    }
    
    func insertDataInSlavebaseBeforePartialSync(){
        if DBManager.sharedInstance().openMasterDatabase() && DBManager.sharedInstance().openSlaveDatabase(){
            let attachDatabaseStatement = "ATTACH DATABASE \'\(DBManager.sharedInstance().slaveDatabase?.databaseURL?.path ?? "")' AS partial"
            if let attachMentSucecess = DBManager.sharedInstance().masterDatabase?.executeStatements(attachDatabaseStatement){
                if(attachMentSucecess){
                    if let alltable = DBManager.sharedInstance().getAllTableFromMasterDatabase(){
                        for table in alltable{
                            let masterQuery = "INSERT OR REPLACE INTO partial.\(table) SELECT * FROM main.\(table) where is_export = 0"
                            //let masterQuery = "INSERT INTO main.\(table) SELECT * FROM partial.\(table)"
                            let results =   DBManager.sharedInstance().masterDatabase!.executeStatements(masterQuery)
                            
                        }
                    }
                }
            }
        }
    }
    
    func updateMasterDbAfterPartialSync(){
       
        if DBManager.sharedInstance().openMasterDatabase(){
        
            if let fileUrl = DBManager._sharedInstance.documentDirecotryPath?.path{
                if FileManager.default.fileExists(atPath:fileUrl + "/" + DBManager._sharedInstance.partialSyncDataBaseFileName + ".sqlite") {
                   let database = FMDatabase(path: fileUrl + "/" + DBManager._sharedInstance.partialSyncDataBaseFileName + ".sqlite")
                    database.open()
                    
                    if(database.open()){
                        
                        if let databaseUrl = database.databaseURL?.path{
                            
                            let attachDatabaseStatement = "ATTACH DATABASE \'\(databaseUrl)' AS partial"
                            
                            if let attachMentSucecess = DBManager.sharedInstance().masterDatabase?.executeStatements(attachDatabaseStatement){
                                if(attachMentSucecess){
                                    if let alltable = DBManager.sharedInstance().getAllTableFromMasterDatabase(){
                                        for table in alltable{
                                            let masterQuery = "INSERT OR REPLACE INTO main.\(table) SELECT * FROM partial.\(table)"
                                                //let masterQuery = "INSERT INTO main.\(table) SELECT * FROM partial.\(table)"
                                                let results =   DBManager.sharedInstance().masterDatabase!.executeStatements(masterQuery)
                                               
                                        }
                                    }
                                    findSqlFilePathsAfterPartialSync()
                                    findSqliteFilePathsAfterPartialSync()
                                }
                            }
                        }
                        DBManager.sharedInstance().masterDatabase?.close()
                    }
                }
            }
        }
    }
    
    func readDataFromSqlFile(fileName : String){
        
        let path = DBManager.sharedInstance().documentDirecotryPath
        
        if let fileUrl = path?.appendingPathComponent(fileName){
            //reading
            do {
                let queryToUpdate = try String(contentsOf: fileUrl, encoding: .utf8)
                let result = updateMasterDatabaseSQLQueryInPartialSync(strQuery: queryToUpdate)
                
                if(result){
                    updateMasterDbAfterPartialSync() // After query updation update master database
                }
            }
            catch {/* error handling here */}
        }
    }
    
    func updateMasterDatabaseSQLQueryInPartialSync (strQuery : String) -> Bool{
        
        if(DBManager.sharedInstance().openMasterDatabase()){
            
            let result = DBManager.sharedInstance().masterDatabase?.executeStatements(strQuery)
            DBManager.sharedInstance().masterDatabase?.close()
            
            return result ?? false
        }
        return false
        
    }
    
    func findSqlFilePathsAfterPartialSync(){
       
        // This will return all the sql file list from document directory
        
        let fileObject = getFileNamesAtDocumentDirectoryByExtension(pathExtension: "sql")
        
        if let arrOfUrls = fileObject.arrOfUrls{
            for url in arrOfUrls.enumerated(){
                deleteFilesAtDocumentDirectory(fileUrl: url.element)
            }
        }
    }
    
    func findSqliteFilePathsAfterPartialSync(){
        
        // This will return all the sqlite file list from document directory
        
        let fileObject = getFileNamesAtDocumentDirectoryByExtension(pathExtension: "sqlite")
        
        if let arrOfUrls = fileObject.arrOfUrls{
            
            for url in arrOfUrls.enumerated(){
               
                if(url.element.lastPathComponent != DBManager.sharedInstance().masterDatabaseFileName){
                    deleteFilesAtDocumentDirectory(fileUrl: url.element)
                }
            }
        }
    }

    
}

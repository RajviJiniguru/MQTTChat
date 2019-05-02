//
//  DBDAO.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 06/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
//import Zip

class DBDAO: NSObject {
    
    static func WSCallPartialSyncDB(fileUrl : URL?,parameters params: [String:Any]?,downloadProgress : @escaping downloadigProgressHandler,successCompletionHandler:  @escaping successCallbackWithData, messageCallBackHandler:@escaping messageCallbackWithData, errorHandler: @escaping errorCallback) {
        
        guard let iPhoneDeviceId =  CurrentDevice.iPhoneDeviceId, let lastSyncDate = Helper.getPREF(UserDefaultsConstant.PREF_SYNC_DATE) else {
            return
        }
        
        let params = [
            WSRequestParams.device_id : iPhoneDeviceId ,
            WSRequestParams.push_registration_id :iPhoneDeviceId,
            WSRequestParams.app_version : CurrentDevice.CurrentAppVersion ?? "1.0",
            WSRequestParams.device_type : CurrentDevice.CurrentDeviceType,
            WSRequestParams.os_version :  CurrentDevice.iPhoneOsVersion,
            WSRequestParams.request_date : lastSyncDate
            ] as [String:String]
        
        if let fileName = fileUrl.map({ $0.lastPathComponent }) {
            
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(fileUrl ?? URL(fileURLWithPath: ""), withName:WSRequestParams.syncFile, fileName: fileName, mimeType: "application/octet-stream")
                    
                    for (key, value) in params {
                        multipartFormData.append((value.data(using: .utf8))!, withName: key)
                    }}, to: WebService.partialDownload, method: .post, headers: WSManager.getHeaders(headersType: .Authorization),
                        encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON {
                                    response in
                                    
                                    switch(response.result) {
                                        
                                    case .success(_):

                                        if let responseDict = response.result.value as? [String: Any] {
                                            if response.response?.statusCode == 200 {
                                                if let statusCode = responseDict["status"] as? Int{
                                                    if statusCode == 0{
                                                        
                                                        if let secretToken = responseDict["newToken"] as? String{
                                                            Helper.setPREF(secretToken, key: UserDefaultsConstant.PREF_SECRET_TOKEN)
                                                        }
                                                        
                                                        messageCallBackHandler(responseDict)
                                                    }else{
                                                        if let data = responseDict[WSResponseParams.data] as? [String:Any] {
                                                            
                                                            deleteFilesAfterPartialSync(slaveDatabaseUrl: DBManager.sharedInstance().slaveDatabase?.databaseURL, zipFileUrl: fileUrl ?? URL(fileURLWithPath: ""))
                                                            
                                                            handleWSCallResponseInitialPartialSync(data: data, isPartialSync: true,downloadProgress: { (progress) in
                                                                downloadProgress(progress)
                                                            },successCompletion: { (fileUrl) in
                                                                
                                                                DBManager.sharedInstance().updateMasterDbAfterPartialSync()
                                                                successCompletionHandler(data)
                                                                
                                                            }, errorCompletion: { (errorMessage) in
                                                                
                                                            })
                                                        }
                                                    }
                                                }
                                                
                                            } else {
                                                messageCallBackHandler(responseDict)
                                            }
                                        }
                                        
                                        break
                                        
                                    case .failure(_):
                                        print(String(data: response.data!, encoding: .utf8))
                                        print(response.result.error ?? "")
                                        break
                                    }
                                }
                            case .failure(let encodingError):
                                print("error:\(encodingError)")
                            }
                })
        }
    }
    
    //------------------------------------------------------------------
    
    static func WSInitialDownloadDbFile(parameters params: [String:Any]?,downloadProgress : @escaping downloadigProgressHandler,successCompletionHandler:  @escaping successCallbackWithData, messageCallBackHandler:@escaping messageCallbackWithData, errorHandler: @escaping errorCallback) {
        
        guard let iPhoneDeviceId =  CurrentDevice.iPhoneDeviceId else {
            return
        }
        
        let params = [
            WSRequestParams.device_id : iPhoneDeviceId ,
            WSRequestParams.push_registration_id :iPhoneDeviceId,
            WSRequestParams.app_version : CurrentDevice.CurrentAppVersion ?? "1.0",
            WSRequestParams.device_type : CurrentDevice.CurrentDeviceType,
            WSRequestParams.os_version : CurrentDevice.iPhoneOsVersion,
            WSRequestParams.request_date : Date().preciseUTCTime
            ] as [String:Any]
        
        request(WebService.initialDownload, method: .post, parameters: params, encoding: JSONEncoding.default,headers: WSManager.getHeaders(headersType: .Authorization)).responseJSON(completionHandler: { (response) in
            print("initialDownload api response :- \n \(response)")
            switch response.result {
            case .success:
                if let responseDict = response.result.value as? [String: Any] {
                    if response.response?.statusCode == 200 {
                        if let data = responseDict[WSResponseParams.data] as? [String:Any] {
                            
                            handleWSCallResponseInitialPartialSync(data: data, isPartialSync: false,downloadProgress: { (progress) in
                                downloadProgress(progress)
                            },successCompletion: { (fileUrl) in

                                Helper.setBoolPREF(true, key: UserDefaultsConstant.PREF_INITIAL_DOWNLOAD)
                                successCompletionHandler(data)
                                
                            }, errorCompletion: { (errorMsg) in
                                
                                // Handle error related stuff here
                                
                            })
                        }
                    } else {
                        messageCallBackHandler(responseDict)
                    }
                }
            case .failure(let error):
                errorHandler(error.localizedDescription)
            }
        })
    }
    
    //------------------------------------------------------------------
    
    static func WSDownloadDbFile(data : [String: Any],isPartialSync : Bool,downloadProgress : @escaping downloadigProgressHandler,successCompletionHandler:  @escaping successCallback,failureCompletionHandler:@escaping errorCallback){
        
        if let url = data[WSResponseParams.filename] as? String,let syncDate = data[WSResponseParams.syncDate] as? String{
    
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            Alamofire.download(
                url,
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: WSManager.getHeaders(headersType: .Authorization),
                to: destination).downloadProgress(closure: { (progress) in
                    //progress closure
//                    print(progress)
                    downloadProgress(CGFloat(progress.fractionCompleted))
                    
                }).response(completionHandler: { (DefaultDownloadResponse) in
                    //here you able to access the DefaultDownloadResponse
                    //result closure
                    
                    if(DefaultDownloadResponse.error != nil){
                        failureCompletionHandler(DefaultDownloadResponse.error?.localizedDescription ?? "")
                        return
                    }
                    
                    Helper.setPREF(syncDate, key:UserDefaultsConstant.PREF_SYNC_DATE)
                    
                    // Extract a Zip file
                    
                    extractDatabaseFromZip(filePath: DefaultDownloadResponse.destinationURL, isPartialSync: isPartialSync, completionHandler: {
                        successCompletionHandler(DefaultDownloadResponse.destinationURL?.absoluteString ?? "")
                    })
                })
        }
    }
    
    //------------------------------------------------------------------
    
    static func handleWSCallResponseInitialPartialSync(data : [String:Any],isPartialSync : Bool,downloadProgress : @escaping downloadigProgressHandler,successCompletion : @escaping successCallback ,errorCompletion : @escaping errorCallback){
        
        // This method will handle response of both initial and partial sync
        WSDownloadDbFile(data: data, isPartialSync: isPartialSync,downloadProgress: { (progress) in
            downloadProgress(progress)
        },successCompletionHandler: { (fileUrl) in
            successCompletion(fileUrl)
        }, failureCompletionHandler: { (errorMsg) in
            errorCompletion(errorMsg)
        })
    }
    
    //------------------------------------------------------------------
    
    static func deleteFilesAfterPartialSync(slaveDatabaseUrl : URL?,zipFileUrl : URL?){
        
        // Delete slave database and zip file once partial sync is done.
        if let slaveDatabaseUrl = slaveDatabaseUrl, let zipFileUrl = zipFileUrl{
            DBManager.sharedInstance().deleteFilesAtDocumentDirectory(fileUrl: slaveDatabaseUrl)
            DBManager.sharedInstance().deleteFilesAtDocumentDirectory(fileUrl: zipFileUrl)
            if let imgPath  = DBManager.sharedInstance().emergancyImageDirectryPath{
                if FileManager.default.fileExists(atPath: imgPath.path){
                    DBManager.sharedInstance().deleteFilesAtDocumentDirectory(fileUrl: imgPath)
                }
            }
        }
    }
    
    //------------------------------------------------------------------
    
}

//
//MARK:- SSZipArchiveDelegate Methods
//

extension DBDAO {
    
    static func extractDatabaseFromZip(filePath : URL?,isPartialSync : Bool,completionHandler : @escaping ()->()){
        
//        if let filePath = filePath,let documentPath = DBManager.sharedInstance().documentDirecotryPath{
//
//            do{
//
//                try Zip.unzipFile(filePath, destination: documentPath, overwrite: true, password: nil, progress: { (progress) in
//
//                    if(progress == 1.0){
//                        DBManager.sharedInstance().deleteFilesAtDocumentDirectory(fileUrl: filePath)
//                        completionHandler()
//                    }
//
//                }, fileOutputHandler: { (url) in
//
//
//                    DBManager.sharedInstance().changeFileNameAtDocumentDirectory(fileUrl: url, fileName: url.lastPathComponent, extensionType: url.pathExtension, newFileName: DBManager.sharedInstance().partialSyncDataBaseFileName + "." + url.pathExtension)
//
//                    //  if(isPartialSync){
//
//                    // This will create a new file name like partial + . + extension type
//
//                    //                        DBManager.sharedInstance().changeFileNameAtDocumentDirectory(fileUrl: url, fileName: url.lastPathComponent, extensionType: url.pathExtension, newFileName: DBManager.sharedInstance().partialSyncDataBaseFileName + "." + url.pathExtension)
//                    //
//                    // }else{
//                    //DBManager.sharedInstance().changeFileNameAtDocumentDirectory(fileUrl: url, fileName: url.lastPathComponent, extensionType: url.pathExtension, newFileName: DBManager.sharedInstance().masterMainDatabaseFileName)
//                    //}
//
//                })
//            }catch{
//                completionHandler()
//            }
//        }
   }
}

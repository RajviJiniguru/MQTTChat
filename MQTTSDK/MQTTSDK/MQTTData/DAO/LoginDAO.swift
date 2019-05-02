//
//  LoginDAO.swift
//  thecareportal
//
//  Created by anil.kukadeja on 31/10/17.
//  Copyright © 2017 tejas.dattani. All rights reserved.
//

import Foundation
import Alamofire
//import Zip


class LoginDAO {
    
    typealias messageCallbackWithData = (([String: Any]) -> Void)
    typealias successCallbackWithData = (([String: Any]) -> Void)
//    typealias successCallbackLoginUser = ((User) -> Void)
    typealias successCallback = ((String) -> Void)
    typealias errorCallback = ((String) -> Void)
    
    //------------------------------------------------------------------
    
    static func WSLoginUser(parameters params: [String:Any], successCompletionHandler:  @escaping successCallbackWithData, messageCallBackHandler:@escaping messageCallbackWithData, errorHandler: @escaping errorCallback) {
        print("params Login User  = \(params)")
        request(WebService.login, method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil).responseJSON(completionHandler: { (response) in
            print("Login user api response :- \n \(response)")
            switch response.result {
            case .success:
                if let responseDict = response.result.value as? [String: Any] {
                    if response.response?.statusCode == 200 {
                        if let data = responseDict[WSResponseParams.data] as? [String:Any] {
                            if let token = data[WSResponseParams.token] as? String{
                                Helper.setPREF(token, key: UserDefaultsConstant.PREF_SECRET_TOKEN)
//                      DBManager.sharedInstance().addDummyDataToClientTaskLogTable()
                            }
                            successCompletionHandler(data)
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
    
//    //------------------------------------------------------------------
//
//    static func WSInitialDownloadDbFile(parameters params: [String:Any]?, successCompletionHandler:  @escaping successCallbackWithData, messageCallBackHandler:@escaping messageCallbackWithData, errorHandler: @escaping errorCallback) {
//
//        guard let iPhoneDeviceId =  CurrentDevice.iPhoneDeviceId else {
//            return
//        }
//
//        let params = [
//            WSRequestParams.device_id : iPhoneDeviceId ,
//            WSRequestParams.push_registration_id :iPhoneDeviceId,
//            WSRequestParams.app_version : CurrentDevice.CurrentAppVersion ?? "1.0",
//            WSRequestParams.device_type : CurrentDevice.CurrentDeviceType,
//            WSRequestParams.os_version : CurrentDevice.iPhoneOsVersion,
//            WSRequestParams.request_date : Date().preciseUTCTime
//        ] as [String:Any]
//
//
//        request(WebService.initialDownload, method: .post, parameters: params, encoding: JSONEncoding.default,headers: WSManager.getHeaders(headersType: .Authorization)).responseJSON(completionHandler: { (response) in
//
//            print("param \(params)")
//            print("headers \(WSManager.getHeaders(headersType: .Authorization))")
//            print("response \(response)")
//
//            print("initialDownload api response :- \n \(response)")
//            switch response.result {
//            case .success:
//                if let responseDict = response.result.value as? [String: Any] {
//                    if response.response?.statusCode == 200 {
//                        if let data = responseDict[WSResponseParams.data] as? [String:Any] {
//
//                            handleWSInitialDownloadDbFile(data: data, successCompletionHandler: { (fileUrl) in
////                                changeFileNameAtDocumentDirectory(fileUrl: fileUrl)
//                                successCompletionHandler(data)
//                            }, failureCompletionHandler: { (errorMsg) in
//                                successCompletionHandler(data)
//                            })
//
//                        }
//                    } else {
//                        messageCallBackHandler(responseDict)
//                    }
//                }
//            case .failure(let error):
//                errorHandler(error.localizedDescription)
//            }
//        })
//    }
    
//    //------------------------------------------------------------------
//
//    static func handleWSInitialDownloadDbFile(data : [String: Any],successCompletionHandler:  @escaping successCallback,failureCompletionHandler:@escaping errorCallback){
//
//        if let url = data[WSResponseParams.filename] as? String{
//
//            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
//
//            Alamofire.download(
//                url,
//                method: .get,
//                parameters: nil,
//                encoding: JSONEncoding.default,
//                headers: WSManager.getHeaders(headersType: .Authorization),
//                to: destination).downloadProgress(closure: { (progress) in
//                    //progress closure
//                    print(progress)
//
//                }).response(completionHandler: { (DefaultDownloadResponse) in
//                    //here you able to access the DefaultDownloadResponse
//                    //result closure
//
//                    if(DefaultDownloadResponse.error != nil){
//                        failureCompletionHandler(DefaultDownloadResponse.error?.localizedDescription ?? "")
//                        return
//                    }
//                    extractDatabaseFromZip(filePath: DefaultDownloadResponse.destinationURL)
//                    successCompletionHandler(DefaultDownloadResponse.destinationURL?.absoluteString ?? "")
//                })
//            }
//    }
    
    //------------------------------------------------------------------
    
    static func handleLoginResponse(data : [String:Any]) {
        
        //Check if user has logged in with we chat or mobile number
//        savePrefernces(data: data)

        print(data)
        
    }
    
    //------------------------------------------------------------------
    
    static func savePrefernces(data : [String:Any]){
//        Helper.setBoolPREF(Value: true, key: UserDefaultsConstant.PREF_IS_USER_LOGGED_IN as NSString)
    }
    
    //------------------------------------------------------------------
}

////
////MARK:- SSZipArchiveDelegate Methods
////
//
//extension LoginDAO {
//    
//    static func extractDatabaseFromZip(filePath : URL?){
//        
//        if let filePath = filePath,let documentPath = DBManager.sharedInstance().documentDirecotryPath{
//            
//            do{
//                try Zip.unzipFile(filePath, destination: documentPath, overwrite: true, password: nil, progress: { (progress) in
//                    
//                }, fileOutputHandler: { (url) in
//                    
//                    print(url)
//                    
//                    let documentDirectory = DBManager.sharedInstance().getFileNamesAtDocumentDirectoryByExtension(pathExtension: "sqlite")
//                    
//                    if let arrOfFileNames = documentDirectory.arrOfFileNames,let arrOfUrls = documentDirectory.arrOfUrls{
//                        
//                        DBManager.sharedInstance().changeFileNameAtDocumentDirectory(fileUrl: arrOfUrls.first, fileName: arrOfFileNames.first, extensionType: ".sqlite", newFileName: DBManager.sharedInstance().masterDatabaseFileName)
//                        
//                    }
//                })
//            }catch{
//                
//            }
//        }
//    }
//}


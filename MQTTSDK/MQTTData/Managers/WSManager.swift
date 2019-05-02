//
//  WSManager.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 01/11/17.
//  Copyright © 2017 Anil. All rights reserved.
//

import Foundation
import Alamofire

enum HeadersType{
    case ApplicationJSON
    case Authorization
    case UpdateChatPassword
}

typealias messageCallbackWithData = (([String: Any]) -> Void)
typealias successCallbackWithData = (([String: Any]) -> Void)
//    typealias successCallbackLoginUser = ((User) -> Void)
typealias successCallback = ((String) -> Void)
typealias errorCallback = ((String) -> Void)
typealias downloadigProgressHandler = ((CGFloat) -> Void)


class WSManager {
    
    static let headers = [
        "Content-type" : "application/json"
    ]
    
    class func getHeaders(headersType:HeadersType)->[String:String]{
        var headers:[String:String] =	[
            "Content-type" : "application/json"
        ]
        
        if headersType == .ApplicationJSON {
            return headers
        } else if headersType == .Authorization {
            if let secretToken = Helper.getPREF(UserDefaultsConstant.PREF_SECRET_TOKEN){
                headers[WSRequestParams.authorization] = "Bearer " + secretToken
            }
            return headers
        }
        else if headersType == .UpdateChatPassword {
            if let secretToken = AuthManager.isAuthenticated()?.token{
                headers[WSRequestParams.chatAuthToken] = secretToken
            }
            if let chatUserId = AuthManager.isAuthenticated()?.userId{
                headers["X-User-Id"] = chatUserId
            }
            
            return headers
        }
    
        else{
            return headers
        }
    }
    

    
    class func wscallAlamoRequest(url : String,method : HTTPMethod,param : [String : Any],headers : HTTPHeaders,successComplitionBlock : @escaping successCallbackWithData,errorcompletionBlock : @escaping errorCallback){
        print(url)
        print(param)
        print(headers)
        Alamofire.request(url, method: method, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch(response.result) {
            case .success(_):
                if let responseDict = response.result.value as? [String: Any] {
                    successComplitionBlock(responseDict)
                }
                break
            case .failure(let error):
                print("Error \(String(data: response.data!, encoding: .utf8))")
                errorcompletionBlock(error.localizedDescription)
                break
            }
        }
    }
    
    class func isConnectedNetwork() -> Bool{
        return NetworkReachabilityManager()!.isReachable
    }
    
    class func downloadfile(url : String,downloadProgress : @escaping downloadigProgressHandler,completionblock : @escaping ((_ downloadurl : URL?) -> ()),errorHandler : @escaping errorCallback){

            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            Alamofire.download(
                url,
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: WSManager.getHeaders(headersType: .Authorization),
                to: destination).downloadProgress(closure: { (progress) in
                    //progress closure
                    downloadProgress(CGFloat(progress.fractionCompleted))
                    
                }).response(completionHandler: { (downloadResponse) in
                    //here you able to access the DefaultDownloadResponse
                    //result closure
                    if downloadResponse.error != nil{
                        errorHandler(downloadResponse.error!.localizedDescription)
                    }
                    else{
                        completionblock(downloadResponse.destinationURL)
                    }
            })
    }
}

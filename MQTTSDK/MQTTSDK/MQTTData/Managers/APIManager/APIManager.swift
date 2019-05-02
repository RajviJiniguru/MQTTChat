//
//  WSManager.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 01/11/17.
//  Copyright © 2017 Anil. All rights reserved.
//

import Foundation
import Alamofire



class APIManager {
    
    static let headers = [
        "Content-type" : "application/json"
    ]
    
   
//        else if headersType == .UpdateChatPassword {
//            if let secretToken = AuthManager.isAuthenticated()?.token{
//                headers[WSRequestParams.chatAuthToken] = secretToken
//            }
//            if let chatUserId = AuthManager.isAuthenticated()?.userId{
//                headers["X-User-Id"] = chatUserId
//            }
//            
//            return headers
//        }


    
    class func wscallAlamoRequest(url : String,method : HTTPMethod,param : [String : Any],headers : HTTPHeaders,successComplitionBlock : @escaping successCallbackWithData,errorcompletionBlock : @escaping errorCallback){
        print(url)
        print(param)
        print(headers)
        Alamofire.request(url, method: method, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch(response.result) {
            case .success(_):
                if let responseDict = response.result.value as? [String: Any]
                {
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
    
    class func uploadImageRequest(url : String,method : HTTPMethod,param : [String : String],headers : HTTPHeaders, image : UIImage, successComplitionBlock : @escaping successCallbackWithData,errorcompletionBlock : @escaping errorCallback)
    {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
         //   if let data = UIImageJPEGRepresentation(image, 0.5) {
            if  let data = image.jpegData(compressionQuality: 0.5) {

                multipartFormData.append(data, withName: "file_data", fileName: "chat.jpeg", mimeType: "chat/jpeg")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    
                    if let responseDict = response.result.value as? [String: Any]
                    {
                        successComplitionBlock(responseDict)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                errorcompletionBlock(error.localizedDescription)
            }
        }
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

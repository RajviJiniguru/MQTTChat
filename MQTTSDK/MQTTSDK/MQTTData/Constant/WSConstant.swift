//
//  WSConstant.swift
//  Sidebar
//
//  Created by Anil K. on 8/5/17
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

struct WebService {
    
    //  "http://192.168.10.40:5050/api/v1/"// Ghanshyam system url
    
    // http://106.14.46.17:4002/ -- Dev url of live server
    // LIVE SERVER URL TO BE APPEND
    static let baseUrl                      = "http://carers-online.transaction.partners/api/v1/"
    static let baseChatEngineUrl            = "http://35.177.27.112:3002"
    //appDelegate.configuration.environment.chatBaseurl
    static let login                        = "\(baseUrl)login"
    static let initialDownload              = "\(baseUrl)initial-download"
    static let partialDownload              = "\(baseUrl)partial-download"
    static let carerImageBaseUrl            = "http://carers-online.transaction.partners/uploads/demo/client_image/"
    
    //"\(appDelegate.configuration.environment.carerImageUrl)"
    static let clientImageBaseUrl           = "http://carers-online.transaction.partners/uploads/demo/client_image/"
    //"\(appDelegate.configuration.environment.clientImageUrl)"
    static let forgotPassword               = "\(baseUrl)forgot-password"
    static let changePassword               = "\(baseUrl)change-password"
    static let userLocation                 = "\(baseUrl)user-location"
    static let userUpdate                = "\(baseChatEngineUrl)/api/v1/users.update"
    static let FetchUserMessages                = "\(baseUrl)fetch-user-messages"

}

struct WSRequestParams {
    static let msg                            = "msg"
    static let version                        = "version"
    static let support                        = "support"
    static let method                         = "method"
    static let id                             = "id"
    static let params                         = "params"
    static let user                           = "user"
    static let password                       = "password"
    static let username                       = "username"
    static let rid                            = "rid"
    static let thread                         = "thread"
    static let email                          = "email"
    static let authorization                  = "Authorization"
    static let device_id                      = "device_id"
    static let push_registration_id           = "push_registration_id"
    static let app_version                    = "app_version"
    static let device_type                    = "device_type"
    static let os_version                     = "os_version"
    static let request_date                   = "request_date"
    static let syncFile                       = "sync_file"
    static let old_password                   = "old_password"
    static let new_password                   = "new_password"
    static let user_id                        = "user_id"
    static let entry_date                     = "entry_date"
    static let longitude                      = "longitude"
    static let latitude                       = "latitude"
    static let chatAuthToken                  = "X-Auth-Token"
    
}

struct WSResponseParams {
    static let msg                          = "msg"
    static let version                      = "version"
    static let support                      = "support"
    static let method                       = "method"
    static let id                           = "id"
    static let message                      = "message"
    static let data                         = "data"
    static let token                        = "token"
    static let filename                     = "filename"
    static let syncDate                     = "sync_date"
    static let newToken                     = "newToken"
}

struct DatabaseFieldName{
    
     static let client_id = "client_id"
     static let care_plan_no = "care_plan_no"
     static let care_plan_start_date = "care_plan_start_date"
     static let client_prefix = "client_prefix"
     static let client_first_name = "client_first_name"
     static let client_last_name = "client_last_name"
     static let client_profile_picture = "client_profile_picture"
     static let client_dob = "client_dob"
     static let client_gender = "client_gender"
     static let client_marital_status =  "client_marital_status"
     static let client_funding = "client_funding"
     static let status = "status"
     static let created_at = "created_at"
     static let updated_at = "updated_at"
     static let deleted_at =  "deleted_at"
    
}

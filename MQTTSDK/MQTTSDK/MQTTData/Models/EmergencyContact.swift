//
//  EmergencyContact.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 02/05/18.
//  Copyright © 2018 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class EmergencyContact: NSObject {

    var contactSlugName : String?
    var contactDetails : [ContactDetails] = []
    
    required override init(){
        
    }
    
    public required init(resultSet : [String:Any]?) {
        
        super.init()
        
        if let resultDictionary = resultSet{
           
            contactSlugName = resultDictionary["contact_slug_name"] as? String
            
            if let arrContacts = resultDictionary["contact_details"] as?  [[String:Any]]{
                for obj in arrContacts{
                    contactDetails.append(ContactDetails(resultSet: obj))
                }
            }
        }
    }
    
}

class ContactDetails : NSObject{
    
    var contactName : String?
    var dateOfBirth : String?
    var gender : String?
    var relationShip : String?
    var position : String?
    var address1 : String?
    var address2 : String?
    var city : String?
    var state : String?
    var country : String?
    var zip : String?
    var mobile : String?
    var landline : String?
    var email : String?
    var preferedContactMethod : PreferredContactMethod?
    
    required override init(){
        
    }
    
    public required init(resultSet : [String:Any]) {
        
        contactName = resultSet["name"] as? String
        dateOfBirth = resultSet["dob"] as? String
        gender = resultSet["gender"] as? String
        relationShip = resultSet["relationship"] as? String
        position = resultSet["position"] as? String
        address1 = resultSet["address1"] as? String
        address2 = resultSet["address2"] as? String
        city = resultSet["city"] as? String
        state = resultSet["state"] as? String
        country =  resultSet["county"] as? String
        zip = resultSet["zip"] as? String
        mobile = resultSet["mobile"] as? String
        landline = resultSet["landline"] as? String
        email = resultSet["email"] as? String
        
//        if let preferedContacts = resultSet["preferred_contact_method"] as? [String:Any]{
//            preferedContactMethod =
//        }
        
        
//        preferedContactMethod = resultSet.string(forColumn: "preferred_contact_method")
    }
}

class PreferredContactMethod : NSObject{
    
    var phone : String?
    var email : String?
    var sms : String?
    var landline : String?
    
    required override init(){
        
    }
    
//    public required override init(resultSet : FMResultSet) {
//        phone = resultSet.string(forColumn: "phone")
//        email = resultSet.string(forColumn: "email")
//        sms = resultSet.string(forColumn: "sms")
//        landline = resultSet.string(forColumn: "landline")
//    }
    
}



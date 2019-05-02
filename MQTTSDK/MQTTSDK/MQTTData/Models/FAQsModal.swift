//
//  FAQsModal.swift
//  thecareportal
//
//  Created by Jayesh on 10/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class FAQsModal: NSObject {

    var question : String?
    var answer : String?
    
    public required init(resultset : FMResultSet){
        // Manage Data
        question = resultset.string(forColumn: "faq_title")
        answer = resultset.string(forColumn: "faq_Description")
    }
    
    required override init(){
        
    }
}

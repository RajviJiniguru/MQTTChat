//
//  OutComeDetailModal.swift
//  thecareportal
//
//  Created by Jayesh on 07/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class OutComeDetailModal {
    
    // Property Declaration
    var outcome_id : String?
    var outcome_title : String?
    var outcome_description : String?
    var total_outcomes : String?
    
    public required init(resultset : FMResultSet) {
        // Manage Data
        outcome_id = resultset.string(forColumn: "outcome_id")
        outcome_title = resultset.string(forColumn: "outcome_title")
        outcome_description = resultset.string(forColumn: "outcome_description")
       
    }
    required init(information : [String:String]){
        outcome_id = information["outcome_id"]
        outcome_title = information["outcome_title"]
        total_outcomes = information["total_outcomes"]
    }
    init() {
        
    }
}

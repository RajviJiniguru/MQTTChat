//
//  TaskInformationModal.swift
//  thecareportal
//
//  Created by Jayesh on 10/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class TaskInformationModal : Equatable{
    
    
    
    var task_log_id : String?
    var task_title : String?
    var task_type : String?
    var task_medicine_notes : String?
    var task_notes : String?
    var outcome_id : String?
    var outcome_title : String?
    var description : String?
    var task_status : String?
    var task_personal_info : String?
    var task_medicine_has_confirmed_note : String?
    var policy_id : String?
    var task_description : String?
    
    public required init(resultset : FMResultSet){
        // Manage Data
        
        task_log_id = resultset.string(forColumn: "task_log_id")
        task_title = resultset.string(forColumn: "task_title")
        task_type = resultset.string(forColumn: "task_type")
        task_medicine_notes = resultset.string(forColumn: "task_medicine_notes")
        task_description = resultset.string(forColumn: "task_description")
        task_notes = resultset.string(forColumn: "task_notes")
        outcome_id = resultset.string(forColumn: "outcome_id")
        outcome_title = resultset.string(forColumn: "outcome_title")
        description = resultset.string(forColumn: "description")
        task_status = resultset.string(forColumn: "task_status")
        task_medicine_has_confirmed_note = resultset.string(forColumn: "task_medicine_has_confirmed_note")
        task_personal_info = resultset.string(forColumn: "task_personal_info")
        policy_id = resultset.string(forColumn: "policy_id")
    }
    
    static func ==(lhs: TaskInformationModal, rhs: TaskInformationModal) -> Bool {
            return lhs.task_log_id == rhs.task_log_id
    }
    
    required init(){
        
    }
}

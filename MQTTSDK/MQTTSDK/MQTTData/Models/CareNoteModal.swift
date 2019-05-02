//
//  CareNoteModal.swift
//  thecareportal
//
//  Created by Jayesh on 13/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class CareNoteModal {
    
    var pending_no_of_task : String?
    var completed_no_of_task : String?
    var incompleted_no_of_task : String?
    var no_of_outcomes : String?
    var care_plan_line_1 : String?
    var care_plan_line_2 : String?
    var visit_description : String?
    var visit_log_id : String?
    var visit_start_time : String?
    
    public required init(resultset : FMResultSet){
        // Manage Data
        pending_no_of_task = resultset.string(forColumn: "pending_no_of_task")
        completed_no_of_task = resultset.string(forColumn: "completed_no_of_task")
        incompleted_no_of_task = resultset.string(forColumn: "incompleted_no_of_task")
        no_of_outcomes = resultset.string(forColumn: "no_of_outcomes")
        care_plan_line_1 = resultset.string(forColumn: "care_plan_line_1")
        care_plan_line_2 = resultset.string(forColumn: "care_plan_line_2")
        visit_description = resultset.string(forColumn: "visit_description")
        visit_log_id = resultset.string(forColumn: "visit_log_id")
        visit_start_time = resultset.string(forColumn: "visit_start_time")?.getConvertDateString(currentdateformatter: DateFormat.DateFormatWithTimeWithSeconds, convdateformatter: DateFormat.DisplayFormat)
    }
    
    required init(){
        
    }
}

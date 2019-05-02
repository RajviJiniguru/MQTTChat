//
//  ClientVisitLogModal.swift
//  thecareportal
//
//  Created by Jayesh on 06/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB

class ClientVisitLogModal {

    var display_date : String?
    var display_start_time : String?
    var display_end_time : String?
    var name : String?
    var visit_log_id : String?
    var client_id : String?
    var visit_title : String?
    var visit_description : String?
    var arrOutcomes : [OutComeDetailModal] = []
    
    public required init(resultset : FMResultSet){
        // Manage Data
        display_date = resultset.string(forColumn: "display_date")
        display_start_time = resultset.string(forColumn: "display_start_time")
        display_end_time = resultset.string(forColumn: "display_end_time")
        name = resultset.string(forColumn: "name")
        visit_log_id = resultset.string(forColumn: "visit_log_id")
        visit_title = resultset.string(forColumn: "visit_title")
        visit_description = resultset.string(forColumn: "visit_description")
        client_id = resultset.string(forColumn: "client_id")
        if let strJson = resultset.object(forColumn:"json_column") as? String{
            let data = strJson.data(using: .utf8)
            do{
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                if let temparr = jsonObj as? [AnyObject]{
                    for obj in temparr{
                        arrOutcomes.append(OutComeDetailModal(information: obj as! [String:String]))
                    }
                }
            }
            catch{
            }
        }
    }
    
    required init(){
       
    }
}

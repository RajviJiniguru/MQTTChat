//
//  CellIdentifierConstant.swift
//  thecareportal
//
//  Created by Jayesh on 25/10/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit

enum FileType : String{
    case zip
    case sqlite
}

let appName = "Carers.Online"
//let appDelegate = UIApplication.shared.delegate as! AppDelegate

// MARK:- Cell Identifier
struct CellIdentifier {
    static let CarePlanSummaryCell = "CarePlanSummaryCell"
    static let TaskInformationCell = "TaskInformationCell"
    static let CarePlanOutComeCell = "CarePlanOutComeCell"
    static let CarePlanVisitCell = "CarePlanVisitCell"
}

// MARK:- ImageNAme
struct ImageName{
    static let AddNote = "icn_add_note"
    static let CompleteStutus = "icn_complete_status"
    static let InCompleteStatus = "icn_incomptask"
    static let PlaceholderImage = "PlaceholderImage"
}

struct DateFormat {
    static let DisplayFormat = "EEEE, MMMM dd, yyyy"
    static let DatabaseDateFormat = "yyyy-MM-dd"
    static let DateFormatWithTimeWithSeconds = "yyyy-MM-dd HH:mm:ss"
    static let DateFormatWithTimeWithoutSeconds = "yyyy-MM-dd HH:mm"
    static let TimeFormat24Hour = "HH:mm"
    static let TimeFormat12Hour = "hh:mm a"
    
}



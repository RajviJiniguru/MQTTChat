//
//  AppConstant.swift
//  Sidebar
//
//  Created by Anil K. on 8/5/17
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

//CurrentDevice constants
struct CurrentDevice {
	static let isiPhone = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
	static let iPhone4S = isiPhone && UIScreen.main.bounds.size.height <= 480
	static let iPhone5	= isiPhone && UIScreen.main.bounds.size.height <= 568.0
	static let iPhone6	= isiPhone && UIScreen.main.bounds.size.height <= 667.0
	static let iPhone6P = isiPhone && UIScreen.main.bounds.size.height <= 736.0
    static let iPhoneOsVersion = String(UIDevice.current.systemVersion)
    static let iPhoneDeviceId = UIDevice.current.identifierForVendor?.uuidString
    static let CurrentAppVersion = UIApplication.shared.applicationVersion() // 1
    static let CurrentDeviceType = "IOS"
}

//App level common constants
struct AppConstants {
//	static let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
	static let PORTRAIT_SCREEN_WIDTH = UIScreen.main.bounds.size.width
	static let PORTRAIT_SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SEND_MESSAGE_TEXTVIEW_HEIGHT = 100
}

struct CellIds {
	static let CELL_ID_MENUCELL                     = "MenuCell"
    static let CELL_ID_MENUVCHEADERCELL             = "MenuVCHeaderCell"
    static let CELL_ID_SEARCHBARVCCELL              = "SearchBarVCCell"
    static let CELL_ID_HELPVCCELL                   = "HelpVCCell"
    static let CELL_ID_FRONTDETAILVCHEADERCELL      = "FrontDetailVCHeaderCell"
    static let CELL_ID_FRONTDETAILDESCRIPTIONCELL   = "FrontDetailDescriptionCell"
    static let CELL_ID_FRONTDETAILDRINKCELL         = "FrontDetailDrinkCell"
    static let CELL_ID_FRONTDETAILVCCALL            = "FrontDetailVCCall"
    static let CELL_ID_FRONTDETAILVCDAYS_HEADER     = "FrontDetailVCDaysHeader"
    static let CELL_ID_FRONTDETAILVCDAYSCELL        = "FrontDetailVCDaysCell"
    static let CELL_ID_FRONTDETAILVCMAPCELL         = "FrontDetailVCMapCell"
    static let CELL_ID_FRONTVCCELL                  = "FrontVCCell"
    static let CELL_ID_FRONTVCMAPCELL               = "FrontVCMapCell"
    static let CELL_ID_FRONTDETAIL_COLLECTION_CELL  = "FrontDetailCollectionCell"
    static let CELL_ID_PAYMENTVC_VISA_CELL          = "PaymentVCVISACell"
    static let CELL_ID_PAYMENTVC_OPTION_CELL        = "PaymentVCOptionCell"
    static let CELL_ID_PAYMENTVC_MEMBERSHIP_CELL    = "PaymentVCMembershipCell"
    static let CELL_ID_PAYMENTVC_AMOUNT_CELL        = "PaymentVCAmountCell"
    static let CELL_ID_PAYMENTVC_SECTION_HEADER_CELL  = "PaymentVCSectionHeader"
    static let CELL_ID_PAYMENTVC_LAST_OPTION_CELL  = "PaymentVCLastOptionCell"
}

// Image names
struct ImageNames{
    static let IMG_SEND = "img_send"
    static let IMG_MIC =  "img_mic"
    static let IMG_LOCK_OPEN = "img_small_lock_open"
    static let IMG_LOCK_CLOSE = "img_small_lock_close"
    static let IMG_PLUS = "img_plus"
    static let IMG_MINUS = "img_minus"
}

//Log messages
struct LogMessages {
	static let LOG_BAD_IMPLEMENTATION		= "Bad Implementation!"
}

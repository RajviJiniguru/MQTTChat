import UIKit
import Foundation

class Helper: NSObject {
	
	class func getViewForNib(nibNamed nibName:String,owner:AnyObject)->UIView{
		return (Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)![0] as? UIView)!
	}
    
    class func getTimezoneOffset() -> String{
        return String(format: "%+.2d:%.2d", 0, 0)
//        let seconds = TimeZone.current.secondsFromGMT()
//        let hours = seconds/3600
//        let minutes = abs(seconds/60) % 60
//        return String(format: "%+.2d:%.2d", hours, minutes)
    }
    
	class func showSingleInputAlert(onVC viewController:UIViewController,title:String,message:String,inputPlaceHolder:String,onCancel:(()->())?,onDone:((_ inputText:String?)->())?){
        
        // shows a single input UIAlert
        
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
				onCancel?()
			}))
			
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_DONE, style:.default, handler: { (action:UIAlertAction) in
				onDone?(alert.textFields?.first?.text)
			}))
			
			alert.addTextField(configurationHandler: { (txtField:UITextField) in
				txtField.placeholder = inputPlaceHolder
				txtField.keyboardType = .emailAddress
			})
            
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
    
	class func showSinglePasswordInputAlert(onVC viewController:UIViewController,title:String,message:String,onCancel:@escaping ()->(),onDone:@escaping (_ password:String)->()){
		DispatchQueue.main.async {
            
            // shows a SinglePassword input UIAlert
            
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
				onCancel()
			}))
			
			
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_DONE, style:.default, handler: { (action:UIAlertAction) in
				onDone((alert.textFields?.first?.text)!)
			}))
			
			alert.addTextField(configurationHandler: { (txtField:UITextField) in
				txtField.placeholder = AlertMessages.ALERT_ENTER_YOUR_PASSWORD
				txtField.isSecureTextEntry = true
			})

			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
	
//	class func showPasswordInputAlert(onVC viewController:UIViewController,title:String,message:String,onCancel:(()->())?,onDone:((_ oldPassword:String?,_ newPassword:String?,_ verifyPassword:String?)->())?){
//		DispatchQueue.main.async {
//            
//              // shows a input UIAlert for password
//            
//			let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//			
//			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
//				onCancel?()
//			}))
//            
//			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_DONE, style:.default, handler: { (action:UIAlertAction) in
//				
//				if let loginType:String = Helper.getPREF(UserDefaults.PREF_LOGIN_TYPE){
//					if loginType == LoginType.Email.rawValue{
//						onDone?(alert.textFields?.first?.text,alert.textFields![1].text,alert.textFields![2].text)
//					}else{
//						onDone?(nil,alert.textFields![0].text,alert.textFields![1].text)
//					}
//				}
//				
//			}))
//			
//			
//			if let loginType:String = Helper.getPREF(UserDefaults.PREF_LOGIN_TYPE){
//				if loginType == LoginType.Email.rawValue{
//					alert.addTextField(configurationHandler: { (txtField:UITextField) in
//						txtField.placeholder = AlertMessages.ALERT_OLD_PASSWORD
//						txtField.isSecureTextEntry = true
//					})
//				}
//			}
//			
//			alert.addTextField(configurationHandler: { (txtField:UITextField) in
//				txtField.placeholder = AlertMessages.ALERT_NEW_PASSWORD
//				txtField.isSecureTextEntry = true
//			})
//			
//			alert.addTextField(configurationHandler: { (txtField:UITextField) in
//				txtField.placeholder = AlertMessages.ALERT_VERIFY_PASSWORD
//				txtField.isSecureTextEntry = true
//			})
//			
//			alert.view.setNeedsLayout()
//			viewController.present(alert, animated: true, completion: nil)
//		}
//	}
	
		
	class func showSettingsAlert(_ title:String,message:String,onVC viewController:UIViewController,onCancel:(()->())?){
        
        // Shows two button UIAlert
        
		DispatchQueue.main.async {
            Helper.show2ButtonsAlert(onVC: viewController, title: title, message: message, button1Title: AlertMessages.ALERT_SETTINGS,button1ActionStyle:UIAlertAction.Style.default, button2Title: AlertMessages.ALERT_CANCEL, onButton1Click: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString){
					UIApplication.shared.openURL(settingsURL)
				}
				}, onButton2Click: {
					onCancel?()
			})
		}
	}
	
    class func show2ButtonsAlert(onVC viewController:UIViewController,title:String,message:String,button1Title:String,button1ActionStyle:UIAlertAction.Style,button2Title:String,onButton1Click:(()->())?,onButton2Click:(()->())?){
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			
			alert.addAction(UIAlertAction(title: button1Title, style:button1ActionStyle, handler: { (action:UIAlertAction) in
				onButton1Click?()
			}))
			
			alert.addAction(UIAlertAction(title: button2Title, style:.default, handler: { (action:UIAlertAction) in
				onButton2Click?()
			}))
			
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
	
	class func showOKAlert(onVC viewController:UIViewController,title:String,message:String){
        
        // Commonly used in entire app to show UIAlert with Ok
        
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_OK, style:.default, handler: nil))
			
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
	
	class func showOKAlertWithCompletion(onVC viewController:UIViewController,title:String,message:String,onOk:@escaping ()->()){
        
        // Commonly used in entire app to show UIAlert with Ok button's completion
        
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_OK, style:.default, handler: { (action:UIAlertAction) in
				onOk()
			}))
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
    
    class func showOKCancelAlertWithCompletion(onVC viewController:UIViewController,title:String,message:String,onOk:@escaping ()->()){
        
        // Commonly used in entire app to show UIAlert with Ok,Cancel button's completion handler (tap event methods of Ok,Cancel)
        
        DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_OK, style:.default, handler: { (action:UIAlertAction) in
                onOk()
            }))
            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
               
            }))
            alert.view.setNeedsLayout()
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    class func showAgreeCancelAlertWithCompletion(onVC viewController:UIViewController,title:String,message:String,onOk:@escaping ()->()){
        
        // Commonly used in entire app to show UIAlert with Ok,Cancel button's completion handler (tap event methods of Ok,Cancel)
        
        DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_AGREE, style:.default, handler: { (action:UIAlertAction) in
                onOk()
            }))
            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
                
            }))
            alert.view.setNeedsLayout()
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
	class func showNoInternetAvailableAlert(onVC viewController:UIViewController){
        
        // Shows a popup when internet connection is not available
        
		DispatchQueue.main.async {
			Helper.showOKAlert(onVC: viewController, title: AlertMessages.ALERT_CANNOT_PROCEED, message: AlertMessages.ALERT_NO_INTERNET)
		}
	}
	
	class func showSomethingWentWrongAlert(onVC viewController:UIViewController){
        
        // Shows a popup SomethingWentWrong
        
		DispatchQueue.main.async {
			Helper.showOKAlert(onVC: viewController, title: AlertMessages.ALERT_SOMETHING_WENT_WRONG, message: AlertMessages.ALERT_PLEASE_TRY_AGAIN)
		}
	}
		
	class func getiOSVersion()->Int{
		
        // gives a iOS version from device.
        
		let iOSVersion = Int(UIDevice.current.systemVersion)
		
		return iOSVersion!
	}
	
	class func getDeviceHeight() -> Int{
		
        // retrives device height from device.
        
		let deviceHeight:Int = Int(UIScreen.main.bounds.size.height)
		
		return deviceHeight
	}
	
	//MARK:- Setting navigation bar
	class func setNavigationBarWithTitleImage(_ navigationItem:UINavigationItem){
		navigationItem.titleView = UIImageView(image: UIImage(named: "img_nav_title_icon"))
	}
	
	
	//MARK:- set and get preferences for NSString
	/*!
	method getPreferenceValueForKey
	abstract To get the preference value for the key that has been passed
	*/
    
    
    // NSUserDefaults methods which have been used in entire app.
    
	class func getPREF(_ key:String)->String?
	{
		return Foundation.UserDefaults.standard.value(forKey: key) as? String
	}
	
	class func getUserPREF(_ key:String)->Data?
	{
		return Foundation.UserDefaults.standard.value(forKey: key as String) as? Data
	}

	/*!
	method setPreferenceValueForKey for int value
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setPREF(_ sValue:String, key:String)
	{
		Foundation.UserDefaults.standard.setValue(sValue, forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	/*!
	method delPREF for string
	abstract To delete the preference value for the key that has been passed
	*/
	
	class func  delPREF(_ key:String)
	{
		Foundation.UserDefaults.standard.removeObject(forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	//MARK:- set and get preferences for Integer
	
	/*!
	method getPreferenceValueForKey for array for int value
	abstract To get the preference value for the key that has been passed
	*/
	class func getIntPREF(_ key:String) -> Int?
	{
		return Foundation.UserDefaults.standard.object(forKey: key as String) as? Int
	}
	
    class func setDataPREF(_ sValue:Data, key:String)
    {
        Foundation.UserDefaults.standard.setValue(sValue, forKey: key)
        Foundation.UserDefaults.standard.synchronize()
    }
	
    class func getDataPREF(_ key:String) -> Data?
    {
        return Foundation.UserDefaults.standard.object(forKey: key as String) as? Data
    }
	/*!
	method setPreferenceValueForKey
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setIntPREF(_ sValue:Int, key:String)
	{
		Foundation.UserDefaults.standard.setValue(sValue, forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	/*!
	method delPREF for integer
	abstract To delete the preference value for the key that has been passed
	*/
	
	class func  delIntPREF(_ key:String)
	{
		Foundation.UserDefaults.standard.removeObject(forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	//MARK:- set and get preferences for Double
	
	/*!
	method getPreferenceValueForKey for array for int value
	abstract To get the preference value for the key that has been passed
	*/
	class func getDoublePREF(_ key:String) -> Double?
	{
		return Foundation.UserDefaults.standard.object(forKey: key as String) as? Double
	}
	
	
	/*!
	method setPreferenceValueForKey
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setDoublePREF(_ sValue:Double, key:String)
	{
		Foundation.UserDefaults.standard.setValue(sValue, forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	//MARK:- set and get preferences for Array
	
	/*!
	method getPreferenceValueForKey for array
	abstract To get the preference value for the key that has been passed
	*/
	class func getArrPREF(_ key:String) -> [Int]?
	{
		return Foundation.UserDefaults.standard.object(forKey: key as String) as? [Int]
	}
	
	
	/*!
	method setPreferenceValueForKey for array
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setArrPREF(_ sValue:[Int], key:String)
	{
		Foundation.UserDefaults.standard.set(sValue, forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	/*!
	method delPREF
	abstract To delete the preference value for the key that has been passed
	*/
	
	class func  delArrPREF(_ key:String)
	{
		Foundation.UserDefaults.standard.removeObject(forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	//MARK:- set and get preferences for Dictionary
	/*!
	method getPreferenceValueForKey for dictionary
	abstract To get the preference value for the key that has been passed
	*/
	class func getDicPREF(_ key:String)-> NSDictionary
	{
		let data = Foundation.UserDefaults.standard.object(forKey: key as String) as! Data
		let object = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: String]
		return object as NSDictionary
		
	}
	
	/*!
	method setPreferenceValueForKey for dictionary
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setDicPREF(_ sValue:NSDictionary, key:String)
	{
		Foundation.UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: sValue), forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
    
    
    class func setDatePREF(_ sDate:Date, key:String)
    {
        Foundation.UserDefaults.standard.set(sDate, forKey: key)
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func getDatePREF(key:String) -> Date?{
        return Foundation.UserDefaults.standard.object(forKey: key) as? Date
    }
    
    
	
	//MARK:- set and get preferences for Boolean
	/*!
	method getPreferenceValueForKey for boolean
	abstract To get the preference value for the key that has been passed
	*/
	class func getBoolPREF(_ key:String) -> Bool {
		return Foundation.UserDefaults.standard.bool(forKey: key as String)
	}
	
	
	/*!
	method setBoolPreferenceValueForKey
	abstract To set the preference value for the key that has been passed
	*/
	
	class func setBoolPREF(_ sValue:Bool , key:String){
		Foundation.UserDefaults.standard.set(sValue, forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
    
	/*!
	method delPREF for boolean
	abstract To delete the preference value for the key that has been passed
	*/
	
	class func  delBoolPREF(_ key:String)
	{
		Foundation.UserDefaults.standard.removeObject(forKey: key as String)
		Foundation.UserDefaults.standard.synchronize()
	}
	
	class func clearPreference(){
		//Remove All preferences
	}
	
		//----------------------------------------------------------------------------------------------------
	//MARK:- check validation of email
	//----------------------------------------------------------------------------------------------------
	
	class func hasAlpha(_ string : NSString) -> Bool {
		
		let wantedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
		
		return (string.rangeOfCharacter(from: wantedCharacters).location == NSNotFound)
	}
	
	class func hasNumber(_ string : NSString) -> Bool {
		
		let wantedCharacters = CharacterSet(charactersIn: "0123456789")
		
		return (string.rangeOfCharacter(from: wantedCharacters).location == NSNotFound)
	}
	
    class func isValidEmail(_ sEmail:String) -> Bool
    {
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        let isValid:Bool = emailTest.evaluate(with: sEmail)
        return isValid
    }
    
	class func getKeysFromWeekDay(_ weekday:Int) -> (startdatekey:String, enddatekey:String,ischeckkey:String) {
		
		if weekday == 1 {
			
			return ("sundaystartdate","sundayenddate","issunday")
		}
		if weekday == 2 {
			
			return ("mondaystartdate","mondayenddate","ismonday")
		}
		if weekday == 3 {
			
			return ("tuesdaystartdate","tuesdayenddate","istuesday")
		}
		if weekday == 4 {
			
			return ("wednessdaystartdate","wednessdayenddate","iswednessday")
		}
		if weekday == 5 {
			
			return ("thursdaystartdate","thursdayenddate","isthursday")
		}
		if weekday == 6 {
			
			return ("fridaystartdate","fridayenddate","isfriday")
		}
		if weekday == 7 {
			
			return ("saturdaystartdate","saturdayenddate","issaturday")
		}
		
		return ("","","")
	}
	
	//MARK:- resizing image
	//----------------------------------------------------------------------------------------------------
	
	class func imageResize (_ imageObj:UIImage, sizeChange:CGSize)-> UIImage{
		
		let hasAlpha = false
		let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage!
	}
	
	//MARK:- get time from dateString
	//----------------------------------------------------------------------------------------------------
	
	class func getTimeFromDateString(_ date:Date) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm a"
		let dateString:String = dateFormatter.string(from: date)
		
		return dateString
	}
	
	//MARK:- get date from dateString
	//----------------------------------------------------------------------------------------------------
	
    class func getStringFromDate(_ date:Date,_dateformat : String) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = _dateformat
		let dateString:String = dateFormatter.string(from: date)
		return dateString
	}
    
	class func getDateFromDateString(_ dateString:NSString) -> Date
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
		//        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")
		let date:Date = dateFormatter.date(from: dateString as String)!
		return date
	}
    
    class func miliSecondToDate(date : Int) -> String {
        
        if date > 0 {
            let dueDate = Date(timeIntervalSince1970:(TimeInterval(date/1000)))
            let formate = DateFormatter()
            formate.dateFormat = "MMM dd, yyyy"
            formate.timeZone =  TimeZone.current
            return formate.string(from: dueDate)
        }
        
        return ""
    }
        
    class func miliSecondToDateWithTime(date : Int) -> String {
            
        if date > 0 {
                
            let dueDate = Date(timeIntervalSince1970:(TimeInterval(date/1000)))
            let formate = DateFormatter()
            formate.dateFormat = "MMM dd, yyyy HH:mm"
            formate.timeZone =  TimeZone.current
            return formate.string(from: dueDate)
            
        }
        
        return ""
    }
	
	//MARK:- Load Html file
	class func loadHtmlFile(_ filename:NSString , webview:UIWebView)
	{
		let file:NSString = filename
		let bundle:Bundle = Bundle.main
		let filePath:NSString = bundle.path(forResource: file as String, ofType: "html")! as NSString
		let fileUrl:URL = URL(fileURLWithPath: filePath as String)
		let request:URLRequest = URLRequest(url: fileUrl)
		webview.loadRequest(request)
	}
	//MARK:- Load URL
	
	class func loadURL(_ url:NSString , webview:UIWebView)
	{
		
		let loadURL:URL = URL(string: url as String)!
		let request = URLRequest(url: loadURL)
		
		webview.loadRequest(request)
	}
	//MARK:- Load Vehicals
	
//    //MARK:- display label for cancel
//    class func displaylblText(_ labelText:NSString , font:UIFont , color:UIColor) -> NSMutableAttributedString
//    {
//
//        let attrLabelString = NSMutableAttributedString(
//            string: labelText as String,
//            attributes: NSDictionary(
//                object:font,
//                forKey: NSFontAttributeName as NSCopying) as? [String : Any])
//        attrLabelString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, attrLabelString.length))
//        return attrLabelString
//    }
	
	//MARK:- covert array to string
	class func arrayToJsonString(_ arrData:NSArray) -> NSString
	{
		let data = try? JSONSerialization.data(withJSONObject: arrData, options: [])
		let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
		return string!
	}
	
	//MARK:- covert string to array
	class func stringToarray(_ string:NSString) -> AnyObject
	{
		
		let dicResponce: AnyObject? = try! JSONSerialization.jsonObject(with: string.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
		
		return dicResponce!
		
	}
	
   
    
	class func convertTimeFromIntToString(_ time: Int) -> String {
		
		if time == -1 {
			return "-"
		}
		
		var newTime = ""
		if time == 0 {
			newTime = "12:00 AM"
		}
		else {
			var suffix = ""
			var hours = floor(Double(time)/100)
			let minutes = floor(Double(time).truncatingRemainder(dividingBy: 100))
			if hours >= 12 {
				hours = hours - 12
				suffix = " PM"
			} else {
				suffix = " AM"
			}
			newTime = String(format: "%02d", Int(hours)) + ":" + String(format: "%02d",  Int(minutes)) + suffix
		}
		return newTime
	}
	
	class func calculateDaysFromStartToEndDate(_ startDate:Date , endDate:Date) -> Int {
		let calendar: Calendar = Calendar.current
		let components = (calendar as NSCalendar).components(NSCalendar.Unit.day , from: startDate, to: endDate,options: [])
		return components.day!
	}
    
    class func showSingleInputForNumberAlert(onVC viewController:UIViewController,title:String,message:String,inputPlaceHolder:String,onCancel:(()->())?,onDone:((_ inputText:String?)->())?){
//        DispatchQueue.main.async {
//            
//            let alert : UIAlertController = UIAlertController.Style: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//            
//            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_CANCEL, style:.default, handler: { (action:UIAlertAction) in
//                onCancel?()
//            }))
//            
//            alert.addAction(UIAlertAction(title: AlertMessages.ALERT_DONE, style:.default, handler: { (action:UIAlertAction) in
//                onDone?(alert.textFields?.first?.text)
//            }))
//            
//            alert.addTextField(configurationHandler: { (txtField:UITextField) in
//                txtField.placeholder = inputPlaceHolder
//                txtField.keyboardType = .numberPad
//            })
//            
//            alert.view.setNeedsLayout()
//            viewController.present(alert, animated: true, completion: nil)
//        }
    }
    
    class func randomAlphaNumericString(length : Int) -> String {
        
        var characters = Array(48...57).map {String(UnicodeScalar($0))}
        characters.append(contentsOf: Array(65...90).map {String(UnicodeScalar($0))})
        characters.append(contentsOf: Array(97...122).map {String(UnicodeScalar($0))})
        var randomString = String(length)
        for _ in 0..<length{
            let length = UInt32(characters.count)
            let randonIndex = Int(arc4random_uniform(length))
            randomString += characters[randonIndex]
        }
        return randomString
    }
}

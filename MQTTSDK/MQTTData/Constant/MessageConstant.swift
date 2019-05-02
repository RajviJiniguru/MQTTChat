//
//  MessageConstant.swift
//  Sidebar
//
//  Created by Anil K. on 8/5/17
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

//Alert constants
struct AlertMessages{
    
    static let APPLICATION_NAME					= ""
    static let ALERT_SUCCESS					= "Success"
    static let ALERT_OK							= "Ok"
    static let ALERT_AGREE                      = "Agree"
    static let ALERT_DONE						= "Done"
    static let ALERT_PROCEED					= "Proceed"
    static let ALERT_WARNING					= "Warning!"
    static let ALERT_TRY_AGAIN					= "Please try again."
    static let ALERT_ERROR_IMAGES_UPLOAD        = "You can only upload 6 images at a time."
    static let ALERT_ERROR_IMAGES_UPLOAD_USER   = "You can only upload 15 images at a time."
    static let ALERT_CANCEL = "Cancel"
    
    static let ALERT_NO_PROMO_ID_SELECTED       = "A promotion must first be added in order to checkout."
    
    static let ALERT_NO_PROMO_ID_FOUND          = "We're sorry \("") is not offering promotions at this time. Please check back again later!"
    
    static let ALERT_NO_RECORD_FOUND            = "Whoops, looks like we can't find any current offers in your area at the moment. Check back again soon, or try changing your location."
    
    static let ALERT_EMAIL						= "Email"
    static let ALERT_SAMPLE_EMAIL_ADDRESS		= "youremail@gmail.com"
    static let ALERT_YOUR_CURRENT_EMAIL_IS		= "Current email address:"
    static let ALERT_CHANGE_EMAIL_ADDRESS		= "Change Email Address"
    static let ALERT_PROVIDE_NEW_EMAIL_ADDRESS	= "Please provide a new email address."
    
    static let ALERT_PASSWORD                   = "Password"
    static let ALERT_NEW_PASSWORD				= "New password can't be empty."
    static let ALERT_RETYPE_PASSWORD				= "Retype password can't be empty."
    
    static let ALERT_OLD_PASSWORD				= "Old Password can't be empty."
    static let ALERT_VERIFY_PASSWORD			= "Retype Password"
    static let ALERT_CHANGE_PASSWORD			= "Change Password"
    
    static let ALERT_CHANGE_CONTACT_INFO		= "Change Contact Information"
    static let ALERT_CURRENT_CONTACT_INFO		= "Your Current Contact Information is : "
    
    static let ALERT_INVALID_OLD_PASSWORD		= "Invalid Old Password"
    static let ALERT_NEW_PASSWORD_NOT_MATCH		= "Sorry, please make sure both passwords match."
    static let ALERT_PROVIDE_VALID_PASSWORDS	= "Please provide a valid password."
    static let ALERT_ENTER_YOUR_PASSWORD		= "Please enter your password"
    static let ALERT_ENTER_CORRECT_OLD_PASSWORD	= "Sorry, this password does not match our records. Please try again."
    
    static let ALERT_EDIT_FIRST_NAME			= "Edit First Name"
    static let ALERT_YOUR_CURRENT_FNAME_IS		= "First name:"
    static let ALERT_EDIT_LAST_NAME				= "Edit Last Name"
    static let ALERT_YOUR_CURRENT_LNAME_IS		= "Last name:"
    static let ALERT_EDIT_LOCATION				= "Edit Location"
    static let ALERT_YOUR_CURRENT_LOCATION_IS	= "Current location:"
    
    static let ALERT_EDIT_BUSINESS_NAME			= "Edit Business Name"
    static let ALERT_YOUR_CURRENT_BUSINESS_IS	= "Business name:"
    
    static let ALERT_EDIT_BUSINESS_ABOUT		= "Edit About"
    static let ALERT_YOUR_CURRENT_BUSINESS_ABOUT = "About:"
    
    static let ALERT_EDIT_NEED_TO_KNOW			= "Edit Need To Know"
    static let ALERT_YOUR_CURRENT_NEED_TO_KNOW	= "Need to know:"
    
    static let ALERT_IMAGE_SELECTED				= "New Image Selected"
    static let ALERT_IMAGE_CHANGE_DESC			= "To save selected image click on \"Save Changes\" button below."
    
    static let ALERT_INVALID_DETAILS			= "Invalid details"
    static let ALERT_PROVIDE_CORRECT_DETAILS	= "Please enter the correct information needed."
    
    static let ALERT_FACEBOOK_TO_EMAIL_TRANSITION_WARNING = "You are currently signed in via Facebook. Updating your email address will force you to login via email in the future."
    static let ALERT_ERROR                     = "Error"
    static let ALERT_TWITTER_LOGIN_FAILED      = "Login with Twitter failed"
    static let ALERT_FB_LOGIN_FAILED           = "Login with Facebok was unsucessful. Please try again."
    static let ALERT_INSTA_LOGIN_FAILED        = "Login with Instagram failed"
    static let ALERT_YELP_LOGIN_FAILED         = "Login with Yelp failed"
    static let ALERT_SOMETHING_WENT_WRONG      = "Whoops, something went wrong. Please refresh and try again."
    static let ALERT_RESTRICTED = "This feature is restricted on your device. Please manage permissions in your device settings."
    static let ALERT_PLEASE_TRY_AGAIN          = "Please try again"
    static let ALERT_CANNOT_PROCEED            = "No internet connection found."
    static let ALERT_NO_INTERNET               = "This actions requires an internet connection."
    static let ALERT_INVALID_ADDRESS           = "Invalid email address. Please try again."
    static let ALERT_PLEASE_TRY_VALID_EMAIL    = "Please enter a valid email address."
    static let ALERT_EMAIL_NOT_VALID           = "The email address entered does not appear to be valid. Please try again."
    static let ALERT_EMAIL_EMPTY               = "The email address field cannot be empty."
    
    static let ALERT_EMAIL_OR_PHONE_EMPTY      = "Please enter a valid email address or phone number to continue."
    
    static let ALERT_INVALID_PASSWORD          = "The password entered is incorrect. Please try again."
    static let ALERT_PASSWORD_EMPTY            = "A valid password must be entered to continue."
    static let ALERT_FIRST_NAME_EMPTY          = "First name must be entered."
    static let ALERT_LAST_NAME_EMPTY           = "Last name must be entered."
    static let ALERT_RE_TYPE_PASSWORD_EMPTY    = "Please make sure both passwords match."
    static let ALERT_PASSWORD_NOT_MATCH        = "The passwords entered do not match. Please try again and enter both passwords the same in both boxes."
    static let ALERT_BUSINESS_NAME_EMPTY       = "Please enter a business name."
    static let ALERT_BUSINESS_CONTACT_NAME_EMPTY = "Please enter the name of the contact for this business."
    static let ALERT_BUSINESS_PHONE_NUMBER_EMPTY	= "Please enter a valid phone number for this business."
    static let ALERT_TAKE_PHOTO					= "Take Photo"
    static let ALERT_CHOOSE_PHOTO				= "Choose Photo"
    static let ALERT_UPLOAD_PHOTO				= "Upload Photo"
    static let ALERT_SOURCE_TYPE_UNSUPPORTED	= "Your device doesn't support this source type."
    static let ALERT_SETTINGS = "Settings"
    static let ALERT_PHONE_NUMBER = "Phone Number"
    static let ALERT_COUNTRY_CODE = "The country code field can not be empty."
    static let ALERT_PHONE_NUMBER_EMPTY = "The phone number field can not be empty."
    static let ALERT_COUNTRY_CODE_EMPTY = "The country code field can not be empty."
    static let ALERT_VALID_EMAIL_ADDRESS = "Please enter valid email address"
    
    static let ALERT_USER_NAME = "User Name"
    static let ALERT_USER_NAME_EMPTY = "User name field can not be empty."
    static let ALERT_QUICK_REPLY                      = "Quick Reply"
    static let ALERT_QUICK_REPLY_PLACEHOLDER                      = "Enter new response"
    static let ALERT_QUICK_REPLY_CANCEL                      = "You have cancelled entery of quick reply message"
    
    static let ALERT_SET_PASSWORD_EMPTY = "Please enter the pin to continue"
    static let ALERT_SET_PIN_DURATION = "Please select one of the duration to continue"
    
    static let ALERT_WOULD_LIKE_TO_ACCESS_CAMERA = "\"Sidebar\"  would like access to your camera."
    static let ALERT_WOULD_LIKE_TO_ACCESS_CAMERA_DESC = "Please allow Sidebar access to continue."
    static let ALERT_WOULD_LIKE_TO_ACCESS_PHOTOS = "\"Sidebar\" would like access to your photos."
    static let ALERT_WOULD_LIKE_TO_ACCESS_PHOTOS_DESC = "Please allow Sidebar access to continue."
    static let ALERT_CAMERA_ACCESS_REQUIRED = "Camera access is required to perform this operation, please grand us the permission."
}

struct StringMessages{
    static let STR_FORGOT_PASSWORD_SENT_EMAIL_TEXT = "We just sent an email to"
    static let STR_FORGOT_PASSWORD_INSTRUCTIONS = "Click the secure link we sent you to reset your password. If you didn't receieve on email check your Spam folder."
    static let STR_LOGIN = "Login"
    static let STR_TYPE_YOUR_MESSAGE = "Type your message"
}

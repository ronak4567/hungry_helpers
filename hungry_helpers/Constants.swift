
import Foundation
import UIKit


let asterik = NSAttributedString(string: "*", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])

let strikeThroughAttribute = [NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)]

let UaeTimeZone = TimeZone(secondsFromGMT: 10800)



let splashAnimationGif = "splashAnimation"

let deviceType = "ios"
let appFont = "SourceSansPro-Regular"
let cellReUseIdentifier = "Cell"
let BusinessServiceCell = "BusinessServiceTableViewCell"
let ViewProfileServicesCell = "ViewProfileServicesListTableViewCell"
let UserListCell  = "UserListTableViewCell"

let tableContentSize = "contentSize"

let ltrMark = "\u{200E}"

let defaultSaloonImage = #imageLiteral(resourceName: "userIcon")


let appDelegateObj = UIApplication.shared.delegate as! AppDelegate

let userDefault = UserDefaults.standard

enum userDefualtKeys:String {
    case currentLanguage = "currentLanguage"
    case otp = "otp"
    case firebaseToken = "firebaseToken"
    case userLoggedIn = "userLoggedIn"
    case UserObject = "UserObject"
    case saloonProfileImage = "saloonProfileImage"
    case saloonCoverImage = "saloonCoverImage"
    case userProfileImage = "userProfileImage"
    case businessApproved = "businessApproved"
    case isBusinessDelete = "isBusinessDelete"
    case unreadNotifications = "unreadNotifications"
    case registeredDate = "registeredDate"
}

// used to check salon type to show values according to home server and salon service

enum salonTypes : String {
    case salon = "salon"
    case home  = "home"
    case both =  "both"
    case edit = "edit"
    case editClient = "editClient"
}

enum screenType : String {
    case BusinessBooking = "BusinessBooking"
}

enum paymentType : String {
    case card = "card"
    case cash = "cash"
}

struct Languages {
    static let english = "En"
    static let Arabic = "Ar"
}

struct appleLanguages {
    static let english = "en"
    static let Arabic = "ar"
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

let appleLanguagesKey = "AppleLanguages"

enum notificationTypes : String {
    case message
    case booking
    case rateUs
    case wallet
    case cashout
    case reminder
}


struct dateFormats {
    /**
     "dd-MM-yyyy"
     */
    static let format1 = "dd-MM-yyyy"
    
    /**
     "hh:mm a"
     */
    static let format2 = "hh:mm a"
    
    /**
     "dd/MM/yyyy"
     */
    static let format3 = "dd/MM/yyyy"
    
    /**
     "dd-MMM"
     */
    static let format4 = "dd-MMM"
    
    /**
     "mm-dd-yyyy  hh:mm a"
     */
    static let format5 = "MM-dd-yyyy hh:mm a"
    
    /**
     "dd MMM YYYY"
     */
    static let format6 = "dd MMM YYYY"
    
    
    /**
      "yyyy-MM-dd HH:mm"
     */
    static let format7 =  "yyyy-MM-dd HH:mm"
    
    /**
     "YYYY-MM-dd hh:mm a"
     */
    static let format8 =  "YYYY-MM-dd hh:mm a"
    
    /**
     "MM-dd-yyyy"
     */
    static let format9 = "MM-dd-yyyy"
    
    static let format10 = "dd MMM, YYYY hh:mm a"
    
    static let format11 = "dd MMM, YYYY"
    
}


enum AppStoryboard : String {
    case Main, Business, Chat
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

func isValidPhone(phone: String) -> Bool {
    
    let phoneRegex = "^[0-9]{10,15}$";
    let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    return valid
}

// User data attributes

enum userAttributes:String {
    case _id = "_id"
    case deviceId = "deviceId"
    case deviceType = "deviceType"
    case phoneNumber = "phoneNumber"
    case notification = "notification"
    case countryCode = "countryCode"
    case area = "area"
    case block = "block"
    case road = "road"
    case houseNumber = "houseNumber"
    case flatNumber = "flatNumber"
    case name = "name"
    case createdAt = "createdAt"
    case accessToken = "accessToken"
    case updatedAt = "updatedAt"
    case isDelete = "isDelete"
    case coverPhoto = "coverPhoto"
    case profileImage = "profileImage"
    case email = "email"
    case longitude = "longitude"
    case latitude = "latitude"
    case language = "language"
    case birthday = "birthday"
    case address2 = "address2"
    case address = "address"
    case lastName = "lastName"
    case __v = "__v"
    case businessId = "businessId"
    case isTemporary = "isTemporary"
    case isBlock = "isBlock"
    case saloonName = "saloonName"
    case isApproved = "isApproved"
    case gender = "gender"
}


import Foundation
import UIKit

/**
 Call this function to print anything on console.
 */

func printToConsole(item: Any) {
    if Configurator.consolePrintingEnabled.boolValue() {
        print(item)
    }
}


/**
 Call this function for showing localized text instead of default nslocalized constructor in every class.
 */

func localizedTextFor(key:String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: getCurrentBundle(), value: "", comment: "")
}


func getCurrentBundle() -> Bundle {
    
    let defaults = UserDefaults.standard
    let langIdArray = defaults.value(forKey: "AppleLanguages") as! Array<String>
    let lanIdCompleteString = langIdArray[0]
    let langId = lanIdCompleteString.prefix(2)
    
    
    if let langBundlePath = Bundle.main.path(forResource: langId.description, ofType: "lproj") {
        
        if let langBundle = Bundle(path: langBundlePath) {
            return langBundle
        }
        else {
            print("Could not load the Mss localized bundle language folder")
        }
    }
    else {
        print("Could not create a path the Mss localized bundle language folder")
    }
    return  Bundle.main
}

func openURLToBrowser(strURL:String) {
    guard let url = URL(string: strURL) else {
      return //be safe
    }

    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

extension Data {
    var html2AttributedString: NSMutableAttributedString? {
        do {
//            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return try NSMutableAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.shadowColor = UIColor.red.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 4.0
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                         y: bounds.maxY - layer.shadowRadius,
                                                         width: bounds.width,
                                                         height: layer.shadowRadius)).cgPath
        //        layer.masksToBounds = false
        //        layer.shadowColor = UIColor.black.cgColor
        //        layer.shadowOpacity = 0.2
        //        layer.shadowOffset = .zero
        //        layer.shadowRadius = 1
        //        layer.shouldRasterize = true
        //        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}


extension String {
    var html2AttributedString: NSMutableAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    var length: Int { return self.count    }  // Swift 2.0
    
    
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func htmlDecoded()->String {

        guard (self != "") else { return self }

        var newStr = self

        let entities = [
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&apos;"    : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
        ]

        for (name,value) in entities {
            newStr = newStr.replacingOccurrences(of: name, with: value)
        }
        return newStr
    }
    
    
    func isNumber() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return self.rangeOfCharacter(from:numberCharacters) == nil
    }
    
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    var pathExtension: String {
        return fileURL.pathExtension
    }
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
}

/**
 Call this function to get any attribute related to logged in user.
 */


/*func getUserData(_ attribute:userAttributes) -> String {
    if attribute == .birthday {
        let birthdateMilliseconds =  appDelegateObj.userDataDictionary.value(forKey: attribute.rawValue) as? NSNumber ?? 0
        printToConsole(item: attribute.rawValue)
        printToConsole(item: birthdateMilliseconds.description)
        return birthdateMilliseconds.description
    }
    else if attribute == .notification {
        let notification =  appDelegateObj.userDataDictionary.value(forKey: attribute.rawValue) as? Int ?? 0
        return notification.description
    } else if attribute == .gender {
        if let gender =  appDelegateObj.userDataDictionary.value(forKey: attribute.rawValue) as? String {
            return gender
        } else {
            return ""
        }
    }
    else if attribute == .isApproved {
        let notification =  appDelegateObj.userDataDictionary.value(forKey: attribute.rawValue) as? Int ?? 0
        return notification.description
    }
    else {
        return appDelegateObj.userDataDictionary.value(forKey: attribute.rawValue) as? String ?? ""
    }
}*/


/**
 Call this function to check if any user is logged in
 */

func isUserLoggedIn() -> Bool {
    return userDefault.bool(forKey: userDefualtKeys.userLoggedIn.rawValue)
}

func getCalendar() -> Calendar {
    var calendar = Calendar.current
    calendar.timeZone = UaeTimeZone!
    return calendar
}

func isCurrentLanguageArabic() -> Bool {
    let languageIdentifier = UserDefaults.standard.value(forKey: userDefualtKeys.currentLanguage.rawValue) as! String
    return languageIdentifier == Languages.Arabic
}

func getDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = UaeTimeZone
    return dateFormatter
}

func getDatePicker() -> UIDatePicker {
    let datePickerView = UIDatePicker()
    datePickerView.locale = Locale(identifier: "en_US")
    if isCurrentLanguageArabic() {
        for views in datePickerView.subviews {
            views.semanticContentAttribute = .forceLeftToRight
        }
    }
    datePickerView.timeZone = UaeTimeZone
    return datePickerView
}


/**
 Call this function to check if business is approved
 */

func isBusinessApproved() -> Bool {
    return userDefault.bool(forKey: userDefualtKeys.businessApproved.rawValue)
}

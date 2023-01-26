/**
 This is a text validator class which contains validation functions for most used cases like email validation, required validation etc.
 */

import UIKit

class Validator: NSObject {
    
    /**
     Call this function to validate email
     */
    
    
    func validateEmail(_ email:String, errorKey:String) -> Bool  {
        //let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        
        if !(emailPredicate.evaluate(with: email)) {
            CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: errorKey))
            return false
        }
        return true
    }
    
    /**
     Call this function to validate equality
     */
    
    func validateEquality(_ firstItem:String, secondItem:String, errorKey:String) -> Bool {
        if secondItem != firstItem {
            CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: errorKey))
            return false
        }
        return true
    }
    
    /**
     Call this function to validate required fields
     */
    
    func validateRequired(_ text:String, errorKey:String) -> Bool {
        if text == "" {
            CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: errorKey))
            return false
        }
        return true
    }
    
    /**
     Call this function to validate null fields
     */
    
    func validateNil(_ item:Any?, errorKey:String) -> Bool {
        if item == nil {
            CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: errorKey))
            return false
        }
        return true
    }
    
    /**
     Call this function to validate string minimum characters count
     */
    
    func validateMinCharactersCount(_ text:String, minCount:Int?, minCountErrorKey:String) -> Bool {
        return validateCharactersCount(text, minCount: minCount, maxCount: nil, minCountErrorKey: minCountErrorKey, maxCountErrorKey: "")
    }
    
    /**
     Call this function to validate string maximum characters count
     */
    
    func validateMaxCharactersCount(_ text:String, maxCount:Int?, maxCountErrorKey:String) -> Bool {
        return validateCharactersCount(text, minCount: nil, maxCount: maxCount, minCountErrorKey: "", maxCountErrorKey: maxCountErrorKey)
    }
    
    /**
     Call this function to validate string minimum and maximum characters count
     */
    
    func validateCharactersCount(_ text:String, minCount:Int?, maxCount:Int?, minCountErrorKey:String, maxCountErrorKey:String) -> Bool {
        if minCount != nil {
            if text.count < minCount! {
                CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: minCountErrorKey))
                return false
            }
        }
        if maxCount != nil {
            if text.count > maxCount! {
                CustomAlertController.sharedInstance.showErrorAlert(error: localizedTextFor(key: maxCountErrorKey))
                return false
            }
        }
        return true
    }
    
}

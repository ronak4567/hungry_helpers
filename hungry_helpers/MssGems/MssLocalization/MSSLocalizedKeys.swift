//
//  MSSLocalizedKeys.swift
//  iBeauty
//
//  Created by Kashish Verma on 3/27/18.
//  Copyright © 2018 Kashish Verma. All rights reserved.
//

import UIKit

class MSSLocalizedKeys: NSObject {
    
    static let sharedInstance = MSSLocalizedKeys()
    private override init() {}
    
    /**
     Call this function for showing localized text from string file using the key.
     */
    
    func localizedTextFor(key:String) -> String {
        return NSLocalizedString(key, tableName: "MSSLocalizable", bundle: Bundle.main, value: "", comment: "")
    }
    
    
    /**
     keys to find text from localized string file
     */
    
    // Custom Image Picker Wrapper
    
    enum CustomImagePickerText:String {
        case openCamera = "openCamera"
        case openGallery = "openGallery"
    }
    
    
    // Validations
    
    enum ValidationsText:String {
        case kNetworkError = "kNetworkError"
        case kJsonError = "kJsonError"
        case kServerError = "kServerError"
    }
    
    
    // General
    
    enum GeneralText:String {
        case no = "no"
        case yes = "yes"
        case cancel = "cancel"
        case cameraPermission = "cameraPermission"
        case permissionHeading = "permissionHeading"
        case ok = "ok"
        case done = "done"
    }

}

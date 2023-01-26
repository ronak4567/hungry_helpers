/** This is custom made class which contains methods written in swift to instantiate the RM Alert Controller third party library which is in objective-C
 URL :- https://github.com/donileo/RMessage
 */
import SwiftMessages

class CustomAlertController: NSObject {
    
    static let sharedInstance = CustomAlertController()
    
    private override init() {}
        
    /**
     This function will show the alert of user defined type with no callBack.
     
     ### Usage Example: ###
     ````
     CustomAlertController.sharedInstance.showAlert(title:"title", subTitle:"subTitle", type:RMessageType.success/error etc.)
     ````
     */
    
//    func showAlert(subTitle:String?, type:RMessageType) {
//        RMessage.showNotification(withTitle: localizedTextFor(key: GeneralText.appName.rawValue), subtitle: subTitle, type: type, customTypeName: nil, duration: 1.5, callback: nil)
//    }
    
    func showAlertWith(title:String, subTitle:String?, theme:Theme, completion: (() -> ())? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        view.configureTheme(theme)
        view.configureDropShadow()
        view.configureContent(title: title, body: subTitle ?? "")
        
        var config = SwiftMessages.Config()
        let duration = SwiftMessages.Duration.seconds(seconds: 2)
        config.duration = duration
        if !UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        config.eventListeners.append() { event in
            if case .didHide = event {
                UIApplication.shared.endIgnoringInteractionEvents()
                completion?()
            }
        }
        
        // Show the message.
        SwiftMessages.show(config: config, view: view)
    }
    
    func showAlertWith(title:String, subTitle:String?, theme:Theme) {
        showAlertWith(title: title, subTitle: subTitle, theme: theme, completion: nil)
    }
    
    func showAlertWith(subTitle:String?, theme:Theme, completion:(() -> ())? = nil) {
        showAlertWith(title: "", subTitle: subTitle, theme: theme, completion: completion)
    }
    
    
    func showAlert(subTitle:String?, type:Theme) {
        showAlertWith(title: "", subTitle: subTitle, theme: type, completion: nil)
    }
    
    func showErrorAlert(error:String) {
        showAlert(subTitle: error, type: .error)
    }
    
    
    
}

    
//    func showAlert(subTitle:String?, type:RMessageType) {
//        RMessage.showNotification(withTitle: "", subtitle: subTitle, type: type, customTypeName: nil, duration: 1.5, callback: nil)
//    }

    
    /**
     This function will show the error alert
     
     ### Usage Example: ###
     ````
     CustomAlertController.sharedInstance.showErrorAlert(error:"error string")
     ````
     */
    
//    func showErrorAlert(error:String) {
//        showAlert(subTitle: error, type: .error)
//    }

//    func showComingSoonAlert() {
//         RMessage.showNotification(withTitle: localizedTextFor(key: GeneralText.comingSoon.rawValue), subtitle: localizedTextFor(key: GeneralText.appName.rawValue), iconImage: nil, type: RMessageType.normal, customTypeName: nil, duration: 1.5, callback: nil, buttonTitle: nil, buttonCallback: nil, at: RMessagePosition.bottom, canBeDismissedByUser: true)
//    }
    
//}

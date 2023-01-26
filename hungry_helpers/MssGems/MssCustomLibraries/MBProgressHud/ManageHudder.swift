/** This is custom made class to show and hide activity indicator
 */
import UIKit
class ManageHudder {
    
    static let sharedInstance = ManageHudder()
    
    var alertWindow: UIWindow?
        
    /**
     This function will show the activity indicator in centre of the screen.
     
     ### Usage Example: ###
     ````
     ManageHudder.sharedInstance.startActivityIndicator()
     ````
     */
    
    func startActivityIndicator() {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.makeKeyAndVisible()
        
        let sourceView = alertWindow?.rootViewController!.view!
        let spinnerView = makeActivityIndicatorView()
        sourceView?.addSubview(spinnerView)
        spinnerView.center = (sourceView?.center)!
        spinnerView.layer.cornerRadius = 5
        
    }
    
    func makeActivityIndicatorView() -> UIView {
        let requiredFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 75.0, height: 80.0))
        let spinnerView = UIView(frame: requiredFrame)
        spinnerView.backgroundColor = UIColor(red: 220.0/256.0, green: 220.0/256.0, blue: 220.0/256.0, alpha: 1.0)
        
        let av = UIActivityIndicatorView()
        av.style = .whiteLarge
        av.color = UIColor.red
        
        spinnerView.addSubview(av)
        av.center = spinnerView.center
        av.startAnimating()
        
        return spinnerView
    }
    
    
    /**
     This function will hide the currently showing activity indicator.
     
     ### Usage Example: ###
     ````
     ManageHudder.sharedInstance.stopActivityIndicator()
     ````
     */
    
    func stopActivityIndicator() {
        if let sourceView = alertWindow?.rootViewController!.view! {
            sourceView.subviews[0].removeFromSuperview()
            alertWindow?.resignKey()
        }
        alertWindow = nil
    }
    
}

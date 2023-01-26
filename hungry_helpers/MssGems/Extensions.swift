/**
 This class contains various useful extension of UIKit objects
 */
import UIKit

extension UITextField {
    
    /**
     This extension always return the trimmed text from the text field.
     
     ### Usage Example: ###
     ````
     textfieldInstance.trimmedText()
     ````
     */
    
    func text_Trimmed() -> String {
        if let actualText = self.text {
            return actualText.trimmingCharacters(in: .whitespaces)
        }
        else {
            return ""
        }
    }
    
    /**
     This extension adds done button on UITextfield keyboards where there is no default button (eg. number pad, phone pad, custom pickers etc.).
     */
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.GeneralText.done.rawValue), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

extension UIViewController {
    
    /**
     This extension hides the text written with the back button of the naviagtion bar.
     */
    
    func hideBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
}

extension UIButton {
    
    /**
     Call this function to set background color of uibutton for any particular state
     */
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension String {
    
    /**
     This extension converts the string into boolean.
     */
    
    func boolValue() -> Bool {
        let nsString = self as NSString
        return nsString.boolValue
    }
    
    /**
     This extension converts the string into Integer.
     */
    
    func intValue() -> Int {
        let nsString = self as NSString
        return nsString.integerValue
    }
    
    /**
     This extension converts the string into float.
     */
    
    func floatValue() -> Float {
        let nsString = self as NSString
        return nsString.floatValue
    }
    
    /**
     This extension checks whether the string is empty
     */
    
    func isEmptyString() -> Bool {
        if self == "" {
            return true
        }
        else {
            return false
        }
    }
}

extension UIView {
    
    /**
     Call this function to add shadow to only bottom part of view
     */
    
    @IBInspectable var bottomShadowColor: UIColor{
        get{
            let color = layer.shadowColor ?? UIColor.clear.cgColor
            return UIColor(cgColor: color)
        }
        set {
            addBottomShadow(color: bottomShadowColor)
        }
    }
    
    @IBInspectable var corner_Radius:CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    //Set Round
    @IBInspectable var Round:Bool {
        set {
            self.layer.cornerRadius = self.frame.size.height / 2.0
        }
        get {
            return self.layer.cornerRadius == self.frame.size.height / 2.0
        }
    }
    
    //Set Border Color
    @IBInspectable var borderColor:UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
    //Set Border Width
    @IBInspectable var borderWidth:CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    func addBottomShadow(color:UIColor) {
        let shadowColor = color.cgColor
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
}

extension UIScrollView {
    
    enum ScrollDirection {
        case Top
        case Right
        case Bottom
        case Left
        
        func contentOffsetWith(scrollView: UIScrollView) -> CGPoint {
            var contentOffset = CGPoint.zero
            switch self {
            case .Top:
                contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            case .Right:
                contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
            case .Bottom:
                contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            case .Left:
                contentOffset = CGPoint(x: -scrollView.contentInset.left, y: 0)
            }
            return contentOffset
        }
    }
    
    /**
     This extension manages the keyboard. This will work correctly only if the constraints are placed properly in storyboard.
     ### Usage Example: ###
     ````
     scrollViewInstance.manageKeyboard()
     ````
     */
    
    func manageKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.akeyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.akeyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func akeyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var contentInset:UIEdgeInsets = self.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.contentInset = contentInset
    }
    
    @objc func akeyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.contentInset = contentInset
    }
    
    func scrollTo(direction: ScrollDirection, animated: Bool = true) {
        self.setContentOffset(direction.contentOffsetWith(scrollView: self), animated: animated)
    }
}

extension UITextView {
    
    /**
     This extension always return the trimmed text from the text view.
     
     ### Usage Example: ###
     ````
     textfieldInstance.trimmedText()
     ````
     */
    
    func text_Trimmed() -> String {
        if let actualText = self.text {
            return actualText.trimmingCharacters(in: .whitespaces)
        }
        else {
            return ""
        }
    }
    
    /**
     This extension adds done button on UITextview keyboards where there is no default button (eg. number pad, phone pad, custom pickers etc.).
     */
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: MSSLocalizedKeys.sharedInstance.localizedTextFor(key: MSSLocalizedKeys.GeneralText.done.rawValue), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}

extension Date {
    
    /**
     Call this function to convert date into milliseconds
     */
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    /**
     Call this function to convert milliseconds into date
     */
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(largeMilliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(largeMilliseconds / 1000))
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    func toolbarPikerWithTitle(mySelect : Selector, title : String) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let heading = UIBarButtonItem(title: title, style: UIBarButtonItem.Style.plain, target: self, action: nil)
        heading.tintColor = .black
        
        toolBar.setItems([spaceButton, heading, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

extension UITabBarController {
    
    /**
     Call this function to hide or show tab bar with animation
     */
    
    func setTabBarVisible(visible:Bool) {
        setTabBarVisible(visible: visible, duration: 0, animated: false)
    }
    
    /**
     Call this function to hide or show tab bar with custom animation and duration
     */
    
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // animation
        UIView.animate(withDuration: duration, animations: {
            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            let width = self.view.frame.width
            let height = self.view.frame.height + offsetY
            self.view.frame = CGRect(x:0, y:0, width: width, height: height)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}

extension UIButton {
    
    func addBadgeToButon(badge: String?) {
        for subview in subviews {
            if subview.tag == 420 {
                subview.removeFromSuperview()
            }
        }
        
        if badge == nil {
            return
        } else {
            if badge == "" {
                return
            } else if badge == "0" {
                return
            } else {
                let badgeLabel = UILabel()
                badgeLabel.tag = 420
                badgeLabel.text = badge
                badgeLabel.textColor = UIColor.white
                badgeLabel.backgroundColor = appBarThemeColor
                badgeLabel.textAlignment = .center
                if badge!.count < 3 {
                    badgeLabel.font = UIFont.systemFont(ofSize: 12)
                    badgeLabel.frame = CGRect(x: 15, y: 0, width: 22, height: 22)
                } else {
                    badgeLabel.font = UIFont.systemFont(ofSize: 10)
                    badgeLabel.frame = CGRect(x: 14, y: 0, width: 26, height: 26)
                }
                
                badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
                badgeLabel.layer.borderColor = UIColor.white.cgColor
                badgeLabel.layer.borderWidth = 2
                badgeLabel.layer.masksToBounds = true
                addSubview(badgeLabel)
            }
        }
    }
}

extension UIApplication {
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}

extension UICollectionViewFlowLayout {
    
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft
    }
}

extension UIViewController {

    func hasSafeArea() -> Bool {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

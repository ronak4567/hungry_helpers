//
//  AppDelegate.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 04/01/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window:UIWindow?
    var userMobile = ""
    var userName = ""
    var arrCategories:[Dictionary<String,Any>] = []
    var arrCities:[Dictionary<String,Any>] = []
    var dictSettingData:Dictionary<String,Any> = [:]
    
    var openAdSecondTime:Bool = false
    var timer:Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().tintColor = UIColor(red: 174.0/256, green: 16.0/256, blue: 129.0/256, alpha: 1.0)
        
        if let userMobile = UserDefaults.standard.string(forKey: "RegisterMobile"){
            self.userMobile = userMobile
        }
        
        if let userName = UserDefaults.standard.string(forKey: "UserName"){
            self.userName = userName
        }
        self.getCitiesData()
        self.getCategoriesData()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        
        self.openAdSecondTime = false
        self.timer?.invalidate()
        self.timer = nil
        exit(0);
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.getFullPageBannerAd), userInfo: nil, repeats: false)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        
        print("applicationWillEnterForeground")
    }
    
    
    func getCategoriesData() {
        let url = ApiEndPoints.Onboarding.getCategories
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get,isLoading: false) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                self.arrCategories = dictResult["category_list"] as! [Dictionary<String, Any>]
            }
        }
    }
    
    func getCitiesData() {
        let url = ApiEndPoints.Onboarding.getCities
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get, isLoading: false) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                self.arrCities = dictResult["city_list"] as! [Dictionary<String, Any>]
            }
        }
    }
    
    @objc func getFullPageBannerAd() {
        let url = ApiEndPoints.Onboarding.getPopupBanner
        let param = ["screen":"news_screen"]
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get, parameters: param, isLoading: false) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                if let dictBanner = dictResult["popup_banner"] as? [String:Any]{
                    
                    if self.openAdSecondTime == false {
                        self.openAdSecondTime = true
                        self.timer?.invalidate()
                        self.timer = nil
                        self.timer = Timer.scheduledTimer(timeInterval: 40.0, target: self, selector: #selector(self.getFullPageBannerAd), userInfo: nil, repeats: false)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.openPopup(dictBanner: dictBanner)
                    }
                    
                }
            }
        }
    }
    
    func openPopup(dictBanner:Dictionary<String,Any>){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let fullPageVC = storyBoard.instantiateViewController(withIdentifier: "FullPageViewController") as! FullPageViewController
        fullPageVC.dictBanner = dictBanner
        fullPageVC.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.keyWindow?.rootViewController?.present(fullPageVC, animated: false, completion: {
            printToConsole(item: "FullPageViewController Dismiss")
        })
    }
    
    @objc func openShareMenu(strMessage:String, image:UIImage?) {
        var textShare = ""
        if let postsharemsg = appDelegateObj.dictSettingData["postsharemsg"] as? String {
            if strMessage != "" {
                textShare = "\(strMessage)\n\(postsharemsg)"
            }else{
                textShare = postsharemsg
            }
            
        }
        
        var shareAll = [textShare] as [Any]
        if let img = image{
            shareAll.append(img)
        }
        
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    
}


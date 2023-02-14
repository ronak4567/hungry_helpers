//
//  RegisterViewController.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 04/01/23.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtMobile:UITextField!
    @IBOutlet var txtCity:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegateObj.currentScreen = ""
    }
    
    @IBAction func tappedOnSubmit(_ sender:UIButton){
        let strName = txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strMobile = txtMobile.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strCity = txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if strName == "" {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter valid name.", type: .warning)
        }else if !isValidPhone(phone: strMobile!) {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter your valid mobile number.", type: .warning)
        }else if strCity == "" {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter city.", type: .warning)
        }else{
            
            let Message = "Hey! Friends for the Benefits of Application, Please Confirm Your Mobile No. : (\(strMobile!)) once Again. You Can't change it later." //"Please be sure the Mobile Number (\(strMobile!)) You entered is correct, otherwise You will not get Application Benefits Later."
            let alert = UIAlertController(title: "Swasthyam", message: Message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "SUBMIT", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                self.callRegisterAPI()
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
    }
    
    func callRegisterAPI() {
        let strName = txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strMobile = txtMobile.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strCity = txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let param:Dictionary<String,String> = ["name":strName!,"mobile":strMobile!,"city":strCity!, "platform":"ios"]
        print(param)
        let url = ApiEndPoints.Onboarding.signup
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post,headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            if((response.status?.isEqual(to: 1)) != nil){
                UserDefaults.standard.set(true, forKey: "RegisterSuccess")
                UserDefaults.standard.set(strMobile, forKey: "RegisterMobile")
                UserDefaults.standard.set(strName, forKey: "UserName")
                appDelegateObj.userMobile = strMobile ?? ""
                appDelegateObj.userName = strName ?? ""
                //NotificationCenter.default.post(name: .refreshTopicAPI, object: nil, userInfo: nil)
                
                CustomAlertController.sharedInstance.showAlertWith(subTitle: dictResult["message"] as! String, theme: .success) {
                    let dashboardTab = self.storyboard?.instantiateViewController(withIdentifier: "DashboardTabbar") as! DashboardTabbar
                    //self.navigationController?.pushViewController(dashboardTab, animated: true)
                    //appDelegateObj.tappedController = dashboardTab
                    let tabNavigationController = UINavigationController(rootViewController: dashboardTab)
                    UIApplication.shared.keyWindow?.rootViewController = tabNavigationController
                }
            }
            printToConsole(item: dictResult)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  InfoViewController.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 24/01/23.
//

import UIKit

class InfoViewController: UIViewController {
    
    
    @IBOutlet var btnAbout:UIButton!
    @IBOutlet var btnTerms:UIButton!
    @IBOutlet var btnContact:UIButton!
    
    @IBOutlet var txtStaticPage:UITextView!
    
    @IBOutlet var txtFullName:UITextField!
    @IBOutlet var txtMobileNo:UITextField!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtInqury:UITextView!
    
    @IBOutlet var scrollViewContact:UIScrollView!
    
    var arrStaticPage:[Dictionary<String,Any>] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        btnAbout.isSelected = true
        btnTerms.isSelected = false
        btnContact.isSelected = false
        getInfoPageData()
        txtInqury.textColor = textFieldPlaceHolderColor
        scrollViewContact.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
        appDelegateObj.currentScreen = ""
    }
    
    func getInfoPageData() {
        let url = ApiEndPoints.Onboarding.getStaticpage
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                self.arrStaticPage = dictResult["staticpage"] as! [Dictionary<String, Any>]
//                self.txtStaticPage.attributedText = (self.arrStaticPage[0]["description"] as? String)?.html2AttributedString
//                self.txtStaticPage.font = UIFont(name: "Metropolis-Regular", size: 15)
                self.showText(self.arrStaticPage[0]["description"] as? String ?? "")
                
            }
        }
    }
    
    func showText(_ text:String){
        let attributedString:NSMutableAttributedString = (text.html2AttributedString!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.txtStaticPage.attributedText = attributedString;
        
        self.txtStaticPage.font = UIFont(name: "Metropolis-Regular", size: 15)
        self.txtStaticPage.textAlignment = .justified;
    }
    
    @IBAction func tappedOnBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedOnButton(_ sender:UIButton){
        btnAbout.backgroundColor = UIColor.clear
        btnTerms.backgroundColor = UIColor.clear
        btnContact.backgroundColor = UIColor.clear
        scrollViewContact.isHidden = true
        if sender.tag == 111 {
            btnAbout.isSelected = true
            btnTerms.isSelected = false
            btnContact.isSelected = false
            btnAbout.backgroundColor = statusBarColor
            self.txtStaticPage.isHidden = false
            //self.txtStaticPage.attributedText = (self.arrStaticPage[0]["description"] as? String)?.html2AttributedString
            //self.txtStaticPage.font = UIFont(name: "Metropolis-Regular", size: 15)
            self.showText(self.arrStaticPage[0]["description"] as? String ?? "")
        }else if sender.tag == 222 {
            btnAbout.isSelected = false
            btnTerms.isSelected = true
            btnContact.isSelected = false
            btnTerms.backgroundColor = statusBarColor
            self.txtStaticPage.isHidden = false
//            self.txtStaticPage.attributedText = (self.arrStaticPage[1]["description"] as? String)?.html2AttributedString
//            self.txtStaticPage.font = UIFont(name: "Metropolis-Regular", size: 15)
            self.showText(self.arrStaticPage[1]["description"] as? String ?? "")
        }else if sender.tag == 333 {
            btnAbout.isSelected = false
            btnTerms.isSelected = false
            btnContact.isSelected = true
            btnContact.backgroundColor = statusBarColor
            self.txtStaticPage.isHidden = true
            scrollViewContact.isHidden = false
        }
    }
    
    @IBAction func tappedOnSubmit(_ sender:UIButton){
        
        let strName = txtFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strMobile = txtMobileNo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strEmail = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strInquiry = txtInqury.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if strName == "" {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter valid name.", type: .warning)
        }else if !isValidPhone(phone: strMobile!) {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter your valid mobile number.", type: .warning)
        }else if strEmail == "" {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter email.", type: .warning)
        }else if strInquiry == "Inquiry" {
            CustomAlertController.sharedInstance.showAlert(subTitle: "Please enter some text in Inquiry.", type: .warning)
        }else{
            self.callContactUpAPI()
        }
    }
    
    func callContactUpAPI() {
        let strName = txtFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strMobile = txtMobileNo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strEmail = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strInquiry = txtInqury.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let param:Dictionary<String,String> = ["name":strName!,"mobile":strMobile!,"email":strEmail!, "inquiry":strInquiry!]
        print(param)
        let url = ApiEndPoints.Onboarding.inquiry
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post,headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            if((response.status?.isEqual(to: 1)) != nil){
                
                CustomAlertController.sharedInstance.showAlertWith(subTitle: dictResult["message"] as? String, theme: .success) {
                    self.txtEmail.text = ""
                    self.txtMobileNo.text = ""
                    self.txtFullName.text = ""
                    self.txtInqury.textColor = textFieldPlaceHolderColor
                    self.txtInqury.text = "Inquiry"
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

extension InfoViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = UIToolbar().toolbarPikerWithTitle(mySelect: #selector(InfoViewController.dismissPicker), title: "        ")
        return true
    }
    
    @objc func dismissPicker(){
        self.view.endEditing(true)
    }
    
}

extension InfoViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = UIToolbar().toolbarPikerWithTitle(mySelect: #selector(InfoViewController.dismissPicker), title: "        ")
        if let text = textView.text, text == "Inquiry"{
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == ""{
            textView.text = "Inquiry"
            textView.textColor = textFieldPlaceHolderColor
        }
        return true
    }
}

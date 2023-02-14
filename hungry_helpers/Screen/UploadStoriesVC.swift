//
//  UploadStoriesVC.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 21/01/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imageViewUpload:UIImageView!
    @IBOutlet var btnDelete:UIButton!
}

class UploadStoriesVC: UIViewController {
    
    @IBOutlet var txtCity:UITextField!
    @IBOutlet var txtCategories:UITextField!
    @IBOutlet var txtTitle:UITextField!
    @IBOutlet var txtDescription:UITextView!
    
    @IBOutlet var collectionImage:UICollectionView!
    @IBOutlet var collectionHeight:NSLayoutConstraint!
    var arrUploadImage:[UIImage] = []
    
    var pickerView:UIPickerView = UIPickerView()
    var selectedField = ""
    var selectedCityId = ""
    var selectedCategoryId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDescription.textColor = textFieldPlaceHolderColor
        pickerView.delegate = self
        pickerView.dataSource = self
        collectionHeight.constant = 0;
        collectionImage.delegate = self
        collectionImage.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
        appDelegateObj.currentScreen = ScreenName.uploadScreen.rawValue

    }
    
    @IBAction func tappedOnUpload(_ sender:UIButton){
        let customPicker = CustomImagePicker()
        customPicker.delegate = self
        customPicker.openImagePicker(controller: self, source: sender)
    }
    
    @IBAction func tappedOnSubmit(_ sender:UIButton){
        
        let strDescription = txtDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedCityId == "" {
            CustomAlertController.sharedInstance.showAlertWith(subTitle: "Please select city.", theme: .warning)
        }else if selectedCategoryId == ""{
            CustomAlertController.sharedInstance.showAlertWith(subTitle: "Please select category.", theme: .warning)
        }else if txtTitle.text == "" {
            CustomAlertController.sharedInstance.showAlertWith(subTitle: "Please enter title.", theme: .warning)
        }else if strDescription == "" {
            CustomAlertController.sharedInstance.showAlertWith(subTitle: "Please enter description.", theme: .warning)
        }else if self.arrUploadImage.count == 0 {
            CustomAlertController.sharedInstance.showAlertWith(subTitle: "Please select image.", theme: .warning)
        }else {
            let url = ApiEndPoints.UploadStories.addStories
            let headerWithform = [
                "Content-Type": "multipart/form-data"
            ]
            let param:Dictionary<String,String> = ["user_mobile": appDelegateObj.userMobile,
                                                   "city": selectedCityId,
                                                   "cid": selectedCategoryId,
                                                   "title": txtTitle.text_Trimmed(),
                                                   "description": txtDescription.text_Trimmed()]
            printToConsole(item: param)
            NetworkingWrapper.sharedInstance.connectWithMultiPart(urlEndPoint: url, httpMethod: .post, parameters: param, images: self.arrUploadImage, imageName: "up_pro_img") { response in
                let dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                if((response.status?.isEqual(to: 1)) != nil){
                    CustomAlertController.sharedInstance.showAlertWith(subTitle: response.message, theme: .success)
                    self.selectedCityId = ""
                    self.selectedCategoryId = ""
                    self.selectedField = ""
                    self.txtTitle.text = ""
                    self.txtCity.text = ""
                    self.txtDescription.text = "Description"
                    self.txtDescription.textColor = textFieldPlaceHolderColor
                    self.txtCategories.text = ""
                    self.arrUploadImage.removeAll()
                    self.collectionHeight.constant = 0
                    self.collectionImage.reloadData()
                    self.view.endEditing(true)
                }else{
                    CustomAlertController.sharedInstance.showAlertWith(subTitle: response.message, theme: .error)
                }
            }
            
//            connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
//                let dictResult = response.result as! Dictionary<String,Any>
//                printToConsole(item: dictResult)
//            }
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
extension UploadStoriesVC: CustomImagePickerProtocol {
    func didFinishPickingImage(image: UIImage) {
        collectionHeight.constant = 100;
        self.arrUploadImage.append(image)
        self.collectionImage.reloadData()
    }
    
    func didCancelPickingImage() {
        
    }
    
}

extension UploadStoriesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUploadImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageViewUpload.image = self.arrUploadImage[indexPath.row]
        cell.btnDelete.addTarget(self, action: #selector(tappedOnRemove(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    @IBAction func tappedOnRemove(_ sender:UIButton){
        self.arrUploadImage.remove(at: sender.tag)
        self.collectionImage.reloadData()
    }
    
}

extension UploadStoriesVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedField == "txtCategories" {
            return appDelegateObj.arrCategories.count
        }else if selectedField == "txtCity" {
            return appDelegateObj.arrCities.count
        }else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedField == "txtCategories" {
            return appDelegateObj.arrCategories[row]["name"] as? String
        }else if selectedField == "txtCity" {
            return appDelegateObj.arrCities[row]["name"] as? String
        }else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedField == "txtCategories" {
            txtCategories.text = appDelegateObj.arrCategories[row]["name"] as? String
            selectedCityId = appDelegateObj.arrCategories[row]["id"] as? String ?? ""
        }else if selectedField == "txtCity" {
            txtCity.text = appDelegateObj.arrCities[row]["name"] as? String
            selectedCategoryId = appDelegateObj.arrCategories[row]["id"] as? String ?? ""
        }
    }
    
    
}

extension UploadStoriesVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = UIToolbar().toolbarPikerWithTitle(mySelect: #selector(UploadStoriesVC.dismissPicker), title: "        ")
        if textField == txtCategories {
            textField.inputView = pickerView
            selectedField = "txtCategories"
        }else if textField == txtCity {
            textField.inputView = pickerView
            selectedField = "txtCity"
        }
        pickerView.reloadAllComponents()
        return true
    }
    
    @objc func dismissPicker(){
        let row  = pickerView.selectedRow(inComponent: 0)
        if selectedField == "txtCategories" {
            txtCategories.text = appDelegateObj.arrCategories[row]["name"] as? String
            selectedCityId = appDelegateObj.arrCategories[row]["id"] as? String ?? ""
        }else if selectedField == "txtCity" {
            txtCity.text = appDelegateObj.arrCities[row]["name"] as? String
            selectedCategoryId = appDelegateObj.arrCategories[row]["id"] as? String ?? ""
        }
        self.view.endEditing(true)
    }
    
}

extension UploadStoriesVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text, text == "Description"{
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == ""{
            textView.text = "Description"
            textView.textColor = textFieldPlaceHolderColor
        }
        return true
    }
}

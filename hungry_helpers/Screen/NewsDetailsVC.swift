//
//  NewsDetailsVC.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 18/01/23.
//

import UIKit

class OtherStoriesCell: UITableViewCell {
    @IBOutlet var lblCategory:UILabel!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var imgStories:UIImageView!
}

class NewsDetailsVC: UIViewController {
    
    var newsId:String = ""
    
    @IBOutlet var imgNewsBanner:UIImageView!
    @IBOutlet var imgAuthor:UIImageView!
    @IBOutlet var btnBookmark:UIButton!
    @IBOutlet var controlCategory:UIControl!
    
    @IBOutlet var lblCategory:UILabel!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblDescription:UILabel!
    @IBOutlet var lblAuthourName:UILabel!
    @IBOutlet var lblAuthorDate:UILabel!
    
    @IBOutlet var collectionKeyword:UICollectionView!
    @IBOutlet var collectionHeight:NSLayoutConstraint!
    var arrKeyword:[String] = []
    
    @IBOutlet var tblOtherStories:UITableView!
    @IBOutlet var tblHeight:NSLayoutConstraint!
    var arrOtherStories:[Dictionary<String,Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNewsDetails()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
        appDelegateObj.currentScreen = ScreenName.newsDetailScreen.rawValue
    }
    
    @IBAction func tappedOnBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedOnBookmark(_ sender:UIButton) {
        var url = ""
        if self.btnBookmark.isSelected {
            url = ApiEndPoints.News.removeBookmark;
        }else{
            url = ApiEndPoints.News.addBookmark;
        }
        
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let param:Dictionary<String,String> = ["user_mobile": appDelegateObj.userMobile,"nid": newsId]
        printToConsole(item: param)
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            printToConsole(item: dictResult)
            CustomAlertController.sharedInstance.showAlertWith(subTitle: dictResult["message"] as? String, theme: .success)
            if self.btnBookmark.isSelected{
                self.btnBookmark.isSelected = false
            }else{
                self.btnBookmark.isSelected = true
            }
        }
    }
    
    @IBAction func tappedOnShare(_ sender:UIButton) {
        if let image = self.imgNewsBanner.image {
            appDelegateObj.openShareMenu(strMessage: self.lblTitle.text ?? "", image: image)
        }else{
            appDelegateObj.openShareMenu(strMessage: self.lblTitle.text ?? "", image: nil)
        }
    }
    
    @IBAction func tappedOnCategory(_ sender:UIControl) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        searchStoriesVC.categoryId = "\(self.controlCategory.tag)"
        searchStoriesVC.keywords = self.lblCategory.text ?? ""
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    @IBAction func tappedOnKeyword(_ sender:UIControl) {
        
    }
    
    
    func getNewsDetails() {
        let url = ApiEndPoints.News.getNewsDetail
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let param:Dictionary<String,String> = ["user_mobile": appDelegateObj.userMobile,"nid": newsId]
        printToConsole(item: param)
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            printToConsole(item: dictResult)
            let dictNewsDetail = dictResult["news_detail"] as! Dictionary<String,Any>
            self.lblTitle.text = dictNewsDetail["name"] as? String
            self.lblAuthourName.text = dictNewsDetail["author_name"] as? String
            self.lblAuthorDate.text = dictNewsDetail["pdate"] as? String
            self.lblCategory.text = dictNewsDetail["category_name"] as? String
            self.controlCategory.tag = Int(dictNewsDetail["cid"] as? String ?? "0") ?? 0
            
            let attributedString:NSMutableAttributedString = ((dictNewsDetail["description"] as? String)?.html2AttributedString)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.lblDescription.attributedText = attributedString;
            
            self.lblDescription.font = UIFont(name: "Metropolis-Regular", size: 15)
            self.lblDescription.textAlignment = .justified;
            
            if let strImgURL = dictNewsDetail["up_pro_img"] as? String {
                self.imgNewsBanner.sd_setImage(with: URL(string: strImgURL), completed: nil)
            }
            
            if let strAuthorImage = dictNewsDetail["author_image"] as? String {
                self.imgAuthor.sd_setImage(with: URL(string: strAuthorImage), completed: nil)
            }
            
            if let strBookmark = dictNewsDetail["bookmark"] as? String , strBookmark == "yes" {
                self.btnBookmark.isSelected = true
            }else{
                self.btnBookmark.isSelected = false
            }
            
            
            if let strKeyword = dictNewsDetail["keywords"] as? String, strKeyword != ""{
                self.arrKeyword = strKeyword.components(separatedBy: ",")
                self.collectionKeyword.reloadData()
            }else{
                self.collectionHeight.constant = 0.0;
            }
            
            self.arrOtherStories = dictResult["other_news_list"] as! [Dictionary<String, Any>]
            self.tblHeight.constant = CGFloat(self.arrOtherStories.count) * 80.0
            self.tblOtherStories.reloadData()
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


extension NewsDetailsVC :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrKeyword.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCell", for: indexPath) as! KeywordCell
        let strKeyword = self.arrKeyword[indexPath.row]
        cell.lblTitle.text = strKeyword.uppercased()
        cell.viewBackground.backgroundColor = keywordColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        let strKeyword = self.arrKeyword[indexPath.row]
        searchStoriesVC.categoryId = ""
        searchStoriesVC.keywords = strKeyword
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
}


extension NewsDetailsVC :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOtherStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherStoriesCell", for: indexPath) as! OtherStoriesCell
        let dictDetail = self.arrOtherStories[indexPath.row]
        cell.lblTitle.text = dictDetail["name"] as? String
        cell.lblCategory.text = (dictDetail["category_name"] as? String)?.uppercased()
        
        if let strImgURL = dictDetail["up_pro_img"] as? String {
            cell.imgStories.sd_setImage(with: URL(string: strImgURL), completed: nil)
        }
        
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictDetail = self.arrOtherStories[indexPath.row]
        let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
        newsDetails.newsId = "\(dictDetail["id"]!)"
        self.navigationController?.pushViewController(newsDetails, animated: true)
        
    }
}

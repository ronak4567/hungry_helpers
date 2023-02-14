//
//  BookMarkListVC.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 24/01/23.
//

import UIKit

class BookMarkListVC: UIViewController {
    
    var noOfData = 0
    var totalRecord = 0
    var loadingData = false;
    var arrBookmarkList:[Dictionary<String,Any>] = []
    
    @IBOutlet var tblNews:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getBookMarkData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
        appDelegateObj.currentScreen = ""
    }
    
    
    func getBookMarkData() {
        let url = ApiEndPoints.News.getBookmark
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let param:Dictionary<String,String> = ["user_mobile":appDelegateObj.userMobile,"start":"\(noOfData)","end":"10"]
        printToConsole(item: param)
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            self.loadingData = false
            if((response.status?.isEqual(to: 1)) != nil){
                let dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                if let record = dictResult["total_records"] as? Int{
                    self.totalRecord = record
                }
                if self.arrBookmarkList.count == 0 {
                    if let arrNewTempData = dictResult["news_list"] as? [Dictionary<String, Any>]{
                        self.arrBookmarkList = arrNewTempData
                    }
                }else{
                    if let arrNewTempData = dictResult["news_list"] as? [Dictionary<String, Any>]{
                        self.arrBookmarkList.append(contentsOf: arrNewTempData)
                    }
                }
                self.noOfData = self.arrBookmarkList.count
                self.tblNews.reloadData();
            }
        }
    }
    
    @IBAction func tappedOnBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedOnBookmark(_ sender:UIButton) {
        
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let newsId = self.arrBookmarkList[sender.tag]["id"] as! String;
        
        let param:Dictionary<String,String> = ["user_mobile": appDelegateObj.userMobile,"nid": newsId]
        printToConsole(item: param)
        var url = ""
        if let strBookmark = self.arrBookmarkList[sender.tag]["bookmark"] as? String , strBookmark == "yes" {
            url = ApiEndPoints.News.removeBookmark
        }else{
            url = ApiEndPoints.News.addBookmark
        }
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            printToConsole(item: dictResult)
            CustomAlertController.sharedInstance.showAlertWith(subTitle: dictResult["message"] as? String, theme: .success)
            self.noOfData = 0;
            self.arrBookmarkList.removeAll()
            self.getBookMarkData()
        }
    }
    
    @IBAction func tappedOnCategory(_ sender:UIControl) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        let dictDetail = self.arrBookmarkList[sender.tag]
        searchStoriesVC.categoryId = dictDetail["cid"] as! String
        searchStoriesVC.keywords = dictDetail["category_name"] as! String
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    @IBAction func tappedOnKeyword(_ sender:UIControl) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        let dictDetail = self.arrBookmarkList[sender.tag]
        searchStoriesVC.categoryId = ""
        searchStoriesVC.keywords = dictDetail["keywords"] as! String
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    @IBAction func tappedOnShare(_ sender:UIButton) {
        let dictDetail = self.arrBookmarkList[sender.tag]
        if let cell = self.tblNews.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? NewsTableCell{
            appDelegateObj.openShareMenu(strMessage: dictDetail["name"] as! String, image: cell.imgBanner.image!)
        }else{
            appDelegateObj.openShareMenu(strMessage: dictDetail["name"] as! String, image: nil)
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

extension BookMarkListVC :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrBookmarkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictDetail:Dictionary<String,Any> = self.arrBookmarkList[indexPath.row];
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell") as! NewsTableCell
        cell.lblTitle.text = dictDetail["name"] as? String
        cell.lblUsername.text = dictDetail["author_name"] as? String
        cell.lblDatetime.text = dictDetail["pdate"] as? String
        cell.lblCategoryName.text = (dictDetail["category_name"] as? String)?.uppercased()
        cell.lblKeywords.text = (dictDetail["keywords"] as? String)?.uppercased()
        
        cell.controlKeyword.backgroundColor = keywordColor
        cell.controlCategory.backgroundColor = categoryColor
        
        if cell.lblCategoryName.text == "" {
            cell.controlCategory.isHidden = true
        }else{
            cell.controlCategory.isHidden = false
        }
        
        if cell.lblKeywords.text == "" || cell.lblKeywords.text == nil {
            cell.controlKeyword.isHidden = true
        }else{
            cell.controlKeyword.isHidden = false
        }
        
        if let strBookmark = dictDetail["bookmark"] as? String , strBookmark == "yes" {
            cell.btnBookmark.isSelected = true
        }else{
            cell.btnBookmark.isSelected = false
        }
        
        cell.btnBookmark.tag = indexPath.row;
        cell.btnBookmark.addTarget(self, action: #selector(tappedOnBookmark(_:)), for: .touchUpInside)
        
        cell.btnShare.tag = indexPath.row;
        cell.btnShare.addTarget(self, action: #selector(tappedOnShare(_:)), for: .touchUpInside)
        
        cell.controlCategory.tag = indexPath.row;
        cell.controlCategory.addTarget(self, action: #selector(tappedOnCategory(_:)), for: .touchUpInside)
        
        cell.controlKeyword.tag = indexPath.row;
        cell.controlKeyword.addTarget(self, action: #selector(tappedOnKeyword(_:)), for: .touchUpInside)
        
        let strAuthorURL:String = dictDetail["author_image"] as! String
        cell.imgProfile.sd_setImage(with: URL(string: strAuthorURL))
        let strBannerURL:String = dictDetail["up_pro_img"] as! String
        cell.imgBanner.sd_setImage(with: URL(string: strBannerURL))
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictDetail = self.arrBookmarkList[indexPath.row]
        let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
        newsDetails.newsId = "\(dictDetail["id"]!)"
        self.navigationController?.pushViewController(newsDetails, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.arrBookmarkList.count - 1
        if !loadingData && indexPath.row == lastElement && self.arrBookmarkList.count < self.totalRecord {
            loadingData = true
            self.getBookMarkData()
        }
    }
}

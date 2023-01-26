//
//  SearchStoriesVC.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 25/01/23.
//

import UIKit

class SearchStoriesVC: UIViewController {
    
    @IBOutlet var tblNews:UITableView!
    @IBOutlet var lblKeyword:UILabel!
    @IBOutlet var lblNoRecords:UILabel!
    var noOfData = 0
    var timer:Timer?
    var counter = 0
    var totalRecord = 0
    var categoryId = ""
    var keywords = ""
    
    var arrNewsList:[Dictionary<String,Any>] = []
    //var arrSliderNewsList:[Dictionary<String,Any>] = []
    //var arrTrendingNewsList:[Dictionary<String,Any>] = []
    var arrNewsBannerList:[Dictionary<String,Any>] = []
    var arrTableData:[Dictionary<String,Any>] = []
    var loadingData = false;
    var noOfRecordfetch = 0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblKeyword.text = self.keywords
        self.getNewsData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
    }
    
    @IBAction func tappedOnBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedOnBookmark(_ sender:UIButton) {
        
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let newsId = self.arrTableData[sender.tag]["id"] as! String;
        
        let param:Dictionary<String,String> = ["user_mobile": appDelegateObj.userMobile,"nid": newsId]
        printToConsole(item: param)
        var url = ""
        if let strBookmark = self.arrTableData[sender.tag]["bookmark"] as? String , strBookmark == "yes" {
            url = ApiEndPoints.News.removeBookmark
        }else{
            url = ApiEndPoints.News.addBookmark
        }
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            let dictResult = response.result as! Dictionary<String,Any>
            printToConsole(item: dictResult)
            CustomAlertController.sharedInstance.showAlertWith(subTitle: dictResult["message"] as? String, theme: .success)
            self.noOfRecordfetch = self.noOfData;
            self.noOfData = 0;
            self.arrNewsList.removeAll()
            self.getNewsData(isCallFromBookmark: true)
        }
    }
    
    func getNewsData(isCallFromBookmark: Bool = false) {
        let url = ApiEndPoints.News.getNews
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var param:Dictionary<String,String> = [:]
        
        if isCallFromBookmark {
            param = ["user_mobile":appDelegateObj.userMobile,"start":"\(noOfData)","end":"\(self.noOfRecordfetch)", "cid":categoryId, "keywords":keywords]
        }else{
            param = ["user_mobile":appDelegateObj.userMobile,"start":"\(noOfData)","end":"10", "cid":categoryId, "keywords":keywords]
        }
        
        printToConsole(item: param)
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            self.loadingData = false
            if((response.status?.isEqual(to: 1)) != nil){
                let dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                
                if let record = dictResult["total_records"] as? Int{
                    self.totalRecord = record
                }
                if self.totalRecord == 0 {
                    self.lblNoRecords.isHidden = false
                    self.tblNews.isHidden = true
                }else{
                    self.lblNoRecords.isHidden = true
                    self.tblNews.isHidden = false
                }
                if self.arrNewsList.count == 0 {
                    if let array = dictResult["news_list"] as? [Dictionary<String, Any>]{
                        self.arrNewsList = array
                    }
                    
                    if let array = dictResult["news_banner"] as? [Dictionary<String, Any>]{
                        self.arrNewsBannerList = array
                    }
                }else{
                    if let array = dictResult["news_list"] as? [Dictionary<String, Any>]{
                        self.arrNewsList.append(contentsOf: array)
                    }
                }
                
                self.noOfData = self.arrNewsList.count
                let result = self.arrNewsList.adding(["category_name":"BannerAd"], afterEvery: 4)
                self.arrTableData = result
                self.tblNews.reloadData();
            }
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

extension SearchStoriesVC :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictDetail:Dictionary<String,Any> = self.arrTableData[indexPath.row];
        if dictDetail["category_name"] as! String  == "BannerAd"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
            let randomInt = Int.random(in: 0..<self.arrNewsBannerList.count)
            let dictBanner = self.arrNewsBannerList[randomInt]
            cell.accessibilityValue = dictBanner["url"] as? String
            cell.imgBanner.sd_setImage(with: URL(string: dictBanner["up_pro_img"] as! String), completed: nil)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell") as! NewsTableCell
            
            
            cell.lblTitle.text = dictDetail["name"] as? String
            cell.lblUsername.text = dictDetail["id"] as? String
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
            
            if cell.lblKeywords.text == "" {
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
            
            let strAuthorURL:String = dictDetail["author_image"] as! String
            cell.imgProfile.sd_setImage(with: URL(string: strAuthorURL))
            let strBannerURL:String = dictDetail["up_pro_img"] as! String
            cell.imgBanner.sd_setImage(with: URL(string: strBannerURL))
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let dictDetail:Dictionary<String,Any> = self.arrTableData[indexPath.row];
        if dictDetail["category_name"] as! String  == "BannerAd"{
            return 230
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictDetail = self.arrTableData[indexPath.row]
        if dictDetail["category_name"] as! String  == "BannerAd"{
            let currentCell = tableView.cellForRow(at: indexPath)
            openURLToBrowser(strURL:currentCell?.accessibilityValue ?? "")
        }else {
            let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
            newsDetails.newsId = "\(dictDetail["id"]!)"
            self.navigationController?.pushViewController(newsDetails, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.arrTableData.count - 1
        if !loadingData && indexPath.row == lastElement && self.arrNewsList.count < self.totalRecord {
            loadingData = true
            self.getNewsData()
        }
    }
}

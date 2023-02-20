//
//  NewsViewController.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 11/01/23.
//

import UIKit
import SDWebImage

class SliderTableCell: UITableViewCell {
    @IBOutlet var sliderColletion:UICollectionView!
    @IBOutlet var pageControl:UIPageControl!
}

class TrendingTblCell: UITableViewCell {
    @IBOutlet var collectionTrending:UICollectionView!
}

class NewsTableCell: UITableViewCell {
    @IBOutlet var imgProfile:UIImageView!
    @IBOutlet var imgBanner:UIImageView!
    @IBOutlet var lblUsername:UILabel!
    @IBOutlet var lblDatetime:UILabel!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var btnShare:UIButton!
    @IBOutlet var btnBookmark:UIButton!
    
    @IBOutlet var lblCategoryName:UILabel!
    @IBOutlet var lblKeywords:UILabel!
    @IBOutlet var controlCategory:UIControl!
    @IBOutlet var controlKeyword:UIControl!
}

class BannerTblCell: UITableViewCell {
    @IBOutlet var imgBanner: UIImageView!
}

class TrendingCollectionCell: UICollectionViewCell {
    @IBOutlet var imgTrending:UIImageView!
    @IBOutlet var lblNumber:UILabel!
    @IBOutlet var lblTitle:UILabel!
}


class NewsViewController: UIViewController {
    
    @IBOutlet var tblNews:UITableView!
    @IBOutlet var controlCity:UIControl!
    @IBOutlet var lblCity:UIControl!
    var noOfData = 0
    var timer:Timer?
    var counter = 0
    
    var selectedCity = ""
    var arrNewsList:[Dictionary<String,Any>] = []
    var arrSliderNewsList:[Dictionary<String,Any>] = []
    var arrTrendingNewsList:[Dictionary<String,Any>] = []
    var arrNewsBannerList:[Dictionary<String,Any>] = []
    var arrTableData:[Dictionary<String,Any>] = []
    var loadingData = false;
    var noOfRecordfetch = 0;
    let chooseCities = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNewsData()
        self.tblNews.estimatedRowHeight = 200
        self.setupChooseCategoryDropDown(self.controlCity);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        appDelegateObj.currentScreen = ScreenName.newsScreen.rawValue
        topColouredBlack()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
    
    @IBAction func tappedOnCategory(_ sender:UIControl) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        let dictDetail = self.arrTableData[sender.tag]
        searchStoriesVC.categoryId = dictDetail["cid"] as! String
        searchStoriesVC.keywords = dictDetail["category_name"] as! String
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    @IBAction func tappedOnKeyword(_ sender:UIControl) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        let dictDetail = self.arrTableData[sender.tag]
        searchStoriesVC.categoryId = ""
        searchStoriesVC.keywords = dictDetail["keywords"] as! String
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    @IBAction func tappedOnShare(_ sender:UIButton) {
        let dictDetail = self.arrTableData[sender.tag]
        if let cell = self.tblNews.cellForRow(at: IndexPath(row: sender.tag+1, section: 0)) as? NewsTableCell{
            appDelegateObj.openShareMenu(strMessage: dictDetail["name"] as! String, image: cell.imgBanner.image!)
        }else{
            appDelegateObj.openShareMenu(strMessage: dictDetail["name"] as! String, image: nil)
        }
    }
    
    @IBAction func tappedOnCities(_ sender:UIControl) {
        chooseCities.show();
    }
    
    func getNewsData(isCallFromBookmark: Bool = false) {
        let url = ApiEndPoints.News.getNews
        let headerWithform = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var param:Dictionary<String,String> = [:]
        
        if isCallFromBookmark {
            param = ["user_mobile":appDelegateObj.userMobile,"start":"\(noOfData)","end":"\(self.noOfRecordfetch)", "city":selectedCity]
        }else{
            param = ["user_mobile":appDelegateObj.userMobile,"start":"\(noOfData)","end":"10", "city":selectedCity]
        }
        
        printToConsole(item: param)
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .post, headers: headerWithform, parameters: param) { response in
            
            
            self.loadingData = false
            if((response.status?.isEqual(to: 1)) != nil){
                let dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                if self.arrNewsList.count == 0 {
                    self.arrNewsList = dictResult["news_list"] as! [Dictionary<String, Any>]
                    self.arrSliderNewsList = dictResult["slider_news_list"] as! [Dictionary<String, Any>]
                    self.arrTrendingNewsList = dictResult["trending_news_list"] as! [Dictionary<String, Any>]
                    self.arrNewsBannerList = dictResult["news_banner"] as! [Dictionary<String, Any>]
                }else{
                    let arrNewTempData = dictResult["news_list"] as! [Dictionary<String, Any>]
                    self.arrNewsList.append(contentsOf: arrNewTempData)
                }
                
                self.noOfData = self.arrNewsList.count
                
                var result = self.arrNewsList.adding(["category_name":"BannerAd"], afterEvery: 4)
                result.insert(["category_name":"TrendingStory"], at: 3)
                self.arrTableData = result
                
                DispatchQueue.main.async {
                    self.timer = nil
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                }
                
                self.tblNews.reloadData();
            }
            
        }
        
    }
    
    @objc func changeImage() {
        
        if let sliderTableCell = tblNews.cellForRow(at: IndexPath(row: 0, section: 0)) as? SliderTableCell {
            if counter < self.arrSliderNewsList.count {
                let index = IndexPath.init(item: counter, section: 0)
                sliderTableCell.sliderColletion.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                sliderTableCell.pageControl.currentPage = counter
                counter += 1
            } else {
                counter = 0
                let index = IndexPath.init(item: counter, section: 0)
                sliderTableCell.sliderColletion.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                sliderTableCell.pageControl.currentPage = counter
                counter = 1
            }
        }
    }
    
    @objc func setupChooseCategoryDropDown(_ sender:UIControl) {
        chooseCities.anchorView = sender
        chooseCities.dismissMode = .onTap
        chooseCities.direction = .bottom
        
        chooseCities.bottomOffset = CGPoint(x: 0, y: chooseCities.bounds.height)
        var arrTopic:[Dictionary<String, Any>] = [["id":"0","name":"All Cities"]]
        arrTopic.append(contentsOf: appDelegateObj.arrCities)
        var arr = [String]()
        for dict in arrTopic {
            let dictTemp = dict as! [String:String]
            arr.append(dictTemp["name"]!)
        }
        // You can also use localizationKeysDataSource instead. Check the docs.
        self.chooseCities.dataSource = arr
        
        // Action triggered on selection
        chooseCities.selectionAction = { [unowned self] (index, item) in
            if let cityId = arrTopic[index]["id"] as? String {
                if cityId == "0"{
                    self.selectedCity = ""
                }else{
                    self.selectedCity = cityId
                }
            }
            self.noOfData = 0;
            self.arrNewsList.removeAll()
            self.getNewsData()
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

extension NewsViewController :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrSliderNewsList.count > 0 {
            return self.arrTableData.count + 1
        }else{
            return self.arrTableData.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.arrSliderNewsList.count > 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableCell", for: indexPath) as! SliderTableCell
            cell.sliderColletion.tag = 1111
            cell.sliderColletion.delegate = self
            cell.sliderColletion.dataSource = self
            cell.pageControl.numberOfPages = self.arrSliderNewsList.count
            
            cell.selectionStyle = .none
            return cell;
        }else{
            
            let dictDetail:Dictionary<String,Any> = self.arrTableData[indexPath.row-1];
            if dictDetail["category_name"] as! String  == "BannerAd"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "BannerTblCell") as! BannerTblCell
                let randomInt = Int.random(in: 0..<self.arrNewsBannerList.count)
                let dictBanner = self.arrNewsBannerList[randomInt]
                cell.accessibilityValue = dictBanner["url"] as? String
                cell.imgBanner.sd_setImage(with: URL(string: dictBanner["up_pro_img"] as! String), completed: nil)
                cell.selectionStyle = .none
                return cell
            }else if dictDetail["category_name"] as! String  == "TrendingStory"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingTblCell", for: indexPath) as! TrendingTblCell
                cell.collectionTrending.tag = 2222
                cell.collectionTrending.delegate = self
                cell.collectionTrending.dataSource = self
                cell.selectionStyle = .none
                return cell;
            }else{
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
                
                cell.btnBookmark.tag = indexPath.row - 1;
                cell.btnBookmark.addTarget(self, action: #selector(tappedOnBookmark(_:)), for: .touchUpInside)
                
                cell.btnShare.tag = indexPath.row - 1;
                cell.btnShare.addTarget(self, action: #selector(tappedOnShare(_:)), for: .touchUpInside)
                
                cell.controlCategory.tag = indexPath.row - 1;
                cell.controlCategory.addTarget(self, action: #selector(tappedOnCategory(_:)), for: .touchUpInside)
                
                cell.controlKeyword.tag = indexPath.row - 1;
                cell.controlKeyword.addTarget(self, action: #selector(tappedOnKeyword(_:)), for: .touchUpInside)
                
                
                
                let strAuthorURL:String = dictDetail["author_image"] as! String
                cell.imgProfile.sd_setImage(with: URL(string: strAuthorURL))
                let strBannerURL:String = dictDetail["up_pro_img"] as! String
                cell.imgBanner.sd_setImage(with: URL(string: strBannerURL))
                cell.selectionStyle = .none
                return cell
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.arrSliderNewsList.count > 0 && indexPath.row == 0 {
            let height = (ScreenSize.SCREEN_WIDTH * 230) / 414
            return height
        }else{
            let dictDetail:Dictionary<String,Any> = self.arrTableData[indexPath.row-1];
            if dictDetail["category_name"] as! String  == "BannerAd"{
                return 230
            }else if dictDetail["category_name"] as! String  == "TrendingStory"{
                return 200
            }else{
                return UITableView.automaticDimension
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrSliderNewsList.count > 0 && indexPath.row == 0 {
        }else{
            let dictDetail = self.arrTableData[indexPath.row-1]
            if dictDetail["category_name"] as! String  == "BannerAd"{
                let currentCell = tableView.cellForRow(at: indexPath)
                openURLToBrowser(strURL:currentCell?.accessibilityValue ?? "")
            }else if dictDetail["category_name"] as! String  == "TrendingStory"{
            }else {
                let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
                newsDetails.newsId = "\(dictDetail["id"]!)"
                self.navigationController?.pushViewController(newsDetails, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = self.arrTableData.count - 1
        if !loadingData && indexPath.row == lastElement {
            loadingData = true
            self.getNewsData()
        }
    }
    
    
}

extension NewsViewController :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1111{
            return self.arrSliderNewsList.count
        }else {
            return self.arrTrendingNewsList.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1111{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
            let dictDetail = self.arrSliderNewsList[indexPath.row]
            cell.lblAuthorName.text = dictDetail["category_name"] as? String
            cell.lblTitle.text = dictDetail["name"] as? String
            let strImgURL = "\(dictDetail["up_pro_img"] as! String)"
            cell.imageSlider.sd_setImage(with: URL(string: strImgURL), completed: nil)
            cell.imageSlider.dropShadow()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCollectionCell", for: indexPath) as! TrendingCollectionCell
            let dictDetail = self.arrTrendingNewsList[indexPath.row]
            cell.lblNumber.text = "\(indexPath.row+1)/\(self.arrTrendingNewsList.count)"
            cell.lblTitle.text = dictDetail["name"] as? String
            let strImgURL = "\(dictDetail["up_pro_img"] as! String)"
            cell.imgTrending.sd_setImage(with: URL(string: strImgURL), completed: nil)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1111{
            let dictDetail = self.arrSliderNewsList[indexPath.row]
            let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
            newsDetails.newsId = "\(dictDetail["id"]!)"
            self.navigationController?.pushViewController(newsDetails, animated: true)
        }
        if collectionView.tag == 2222{
            let dictDetail = self.arrTrendingNewsList[indexPath.row]
            let newsDetails = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsVC") as! NewsDetailsVC
            newsDetails.newsId = "\(dictDetail["id"]!)"
            self.navigationController?.pushViewController(newsDetails, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1111{
            let height = (ScreenSize.SCREEN_WIDTH * 230) / 414
            return CGSize(width: ScreenSize.SCREEN_WIDTH, height: height)
        }else{
            return CGSize(width: ScreenSize.SCREEN_WIDTH-80, height: 168)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 1111{
            return 0.0
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}


extension UIViewController
{
    func topColouredBlack()
    {
        let colouredTopBlack = UIView()
        view.addSubview(colouredTopBlack)
        colouredTopBlack.translatesAutoresizingMaskIntoConstraints = false
        colouredTopBlack.backgroundColor = statusBarColor
        
        NSLayoutConstraint.activate([
            colouredTopBlack.topAnchor.constraint(equalTo: view.topAnchor),
            colouredTopBlack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            colouredTopBlack.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    
}

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension Array {
    func adding(_ element: Element, afterEvery n: Int) -> [Element] {
        guard n > 0 else { fatalError("afterEvery value must be greater than 0") }
        let newcount = self.count + self.count / n
        return (0 ..< newcount).map { (i: Int) -> Element in
            (i + 1) % (n + 1) == 0 ? element : self[i - i / (n + 1)]
        }
    }
}

//
//  ViewController.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 04/01/23.
//

import UIKit
import SDWebImage
class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet var pageControl:UIPageControl!
    var timer = Timer()
    var counter = 0
    
    
    
    var arrBannerList:[Dictionary<String,Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSettingData()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegateObj.currentScreen = ""
    }
    
    func getSettingData() {
        let url = ApiEndPoints.Onboarding.getSettings
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get, isLoading: false) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                self.arrBannerList = dictResult["banner_list"] as! [Dictionary<String, Any>]
                appDelegateObj.dictSettingData = dictResult["settings"] as! Dictionary<String, Any>
                self.pageControl.numberOfPages = self.arrBannerList.count
                self.pageControl.currentPage = 0
                self.sliderCollectionView.reloadData()
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    @objc func changeImage() {
        
        if counter < arrBannerList.count {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = counter
            counter = 1
        }
    }
    
    
    
    @IBAction func tappedOnGetStarted(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: "RegisterSuccess") {
            let dashboardTab = self.storyboard?.instantiateViewController(withIdentifier: "DashboardTabbar") as! DashboardTabbar
            //appDelegate.tappedController = dashboardTab
            let tabNavigationController = UINavigationController(rootViewController: dashboardTab)
            UIApplication.shared.keyWindow?.rootViewController = tabNavigationController
            //appDelegate.window?.makeKeyAndVisible()
        }else{
            let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            UIApplication.shared.windows.first?.rootViewController = registerVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
        
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.arrBannerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let dictDetail = self.arrBannerList[indexPath.row] as! [String:Any]
        let strImgURL = "\(dictDetail["up_pro_img"] as! String)"
        cell.imageSlider.sd_setImage(with: URL(string: strImgURL), completed: nil)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}


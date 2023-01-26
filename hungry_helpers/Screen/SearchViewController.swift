//
//  SearchViewController.swift
//  hungry_helpers
//
//  Created by Hari Prabodham on 16/01/23.
//

import UIKit

class CategoriesCell: UICollectionViewCell {
    @IBOutlet var imgCategories:UIImageView!
    @IBOutlet var lblTitle:UILabel!
}

class KeywordCell: UICollectionViewCell {
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var viewBackground:UIView!
}


class SearchViewController: UIViewController {
    
    
    var arrKeyword:[Dictionary<String,Any>] = []
    
    @IBOutlet var collectionCategories:UICollectionView!
    @IBOutlet var collectionKeyword:UICollectionView!
    @IBOutlet var txtSearch:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        getKeywordData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()
    }
    
    
    
    
    
    func getKeywordData() {
        let url = ApiEndPoints.Onboarding.getKeywords
        NetworkingWrapper.sharedInstance.connect(urlEndPoint: url, httpMethod: .get) { (response) in
            
            if((response.status?.isEqual(to: 1)) != nil){
                var dictResult = response.result as! Dictionary<String,Any>
                printToConsole(item: dictResult)
                self.arrKeyword = dictResult["keywords_list"] as! [Dictionary<String, Any>]
                self.collectionKeyword.reloadData()
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

extension SearchViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        searchStoriesVC.categoryId = ""
        searchStoriesVC.keywords = textField.text_Trimmed()
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
        self.view.endEditing(true)
        return true
    }
}


extension SearchViewController :UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.collectionCategories == collectionView){
            return appDelegateObj.arrCategories.count
        }else{
            return self.arrKeyword.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (self.collectionCategories == collectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
            
            let dictDetail = appDelegateObj.arrCategories[indexPath.row]
            cell.lblTitle.text = (dictDetail["name"] as? String)?.uppercased()
            if let strImgURL = dictDetail["up_pro_img"] as? String {
                cell.imgCategories.sd_setImage(with: URL(string: strImgURL), completed: nil)
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCell", for: indexPath) as! KeywordCell
            
            let dictDetail = self.arrKeyword[indexPath.row]
            cell.lblTitle.text = (dictDetail["name"] as? String)?.uppercased()
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchStoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoriesVC") as! SearchStoriesVC
        
        if (self.collectionCategories == collectionView){
            let dictDetail = appDelegateObj.arrCategories[indexPath.row]
            searchStoriesVC.categoryId = dictDetail["id"] as! String
            searchStoriesVC.keywords = dictDetail["name"] as! String
        }else{
            let dictDetail = self.arrKeyword[indexPath.row]
            searchStoriesVC.keywords = dictDetail["name"] as! String
        }
        
        self.navigationController?.pushViewController(searchStoriesVC, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenSize.SCREEN_WIDTH) / 3
        return CGSize(width: width, height: width + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

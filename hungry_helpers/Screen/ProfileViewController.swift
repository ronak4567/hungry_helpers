//
//  ProfileViewController.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 22/01/23.
//

import UIKit
import StoreKit
class MenuCell:UITableViewCell {
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblDescription:UILabel!
}

class ProfileViewController: UIViewController {
    
    var arrMenu:[Dictionary<String,String>] = []
    @IBOutlet var tblMenu:UITableView!
    @IBOutlet var lblUserName:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        arrMenu.append(["title":"My Bookmarks", "description":"Your Bookmarked Stories, Events etc..."])
        arrMenu.append(["title":"App Info", "description":"About, Terms & Privacy, Contact"])
        arrMenu.append(["title":"Rate Our App", "description":"Give us 5 star on the App Store"])
        arrMenu.append(["title":"Invite Friends", "description":"Tell Your Friend to use This App"])
        tblMenu.estimatedRowHeight = 50;
        
        self.lblUserName.text = appDelegateObj.userName
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        topColouredBlack()

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

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        cell.lblTitle.text = self.arrMenu[indexPath.row]["title"]
        cell.lblDescription.text = self.arrMenu[indexPath.row]["description"]
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let bookmarkVC = self.storyboard?.instantiateViewController(withIdentifier: "BookMarkListVC") as! BookMarkListVC
            self.navigationController?.pushViewController(bookmarkVC, animated: true)
        }else if indexPath.row == 1 {
            let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
            self.navigationController?.pushViewController(infoVC, animated: true)
        }else if indexPath.row == 2 {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                
            }
        }else if indexPath.row == 3 {
            self.openShareMenu()
        }
    }
    
    @objc func openShareMenu() {
        var textShare = ""
        if let strMessage = appDelegateObj.dictSettingData["appsharemsg"] as? String {
            textShare = strMessage
        }
        
        let shareAll = [textShare] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
}

//
//  FullPageViewController.swift
//  hungry_helpers
//
//  Created by Ronak Gondaliya on 24/01/23.
//

import UIKit

class FullPageViewController: UIViewController {
    
    @IBOutlet var imageBanner:UIImageView!
    @IBOutlet var heightImageBanner:NSLayoutConstraint!
    var dictBanner:[String:Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnLatestImage))
        imageBanner.addGestureRecognizer(tapGes)
        imageBanner.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedOnLatestImage() {
        if let strURL = dictBanner["url"] as? String {
            openURLToBrowser(strURL: strURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let strURL = dictBanner["up_pro_img"] as? String {
            self.imageBanner.sd_setImage(with: URL(string: strURL)) { (image, error, type, url) in
                if let img = image {
                    let height = ((img.size.height) * (ScreenSize.SCREEN_WIDTH - 40)) / img.size.width
                    self.heightImageBanner.constant = height
                }
            }
        }
        
    }
    
    @IBAction func tappedCloseView(_ sender:UIButton){
        self.dismiss(animated: true) {
            
        }
    }
}

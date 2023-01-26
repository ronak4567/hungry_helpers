//
//  dashboardTabbar.swift
//  Saptapadi
//
//  Created by Ronak Gondaliya on 18/06/20.
//  Copyright © 2020 Ronak Gondaliya. All rights reserved.
//

import UIKit

class DashboardTabbar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        //self.navigationItem.title = "YOUT TITLE NAME";
        
        self.tabBar.items?[0].selectedImage = UIImage(named: "menu_icon1_active")?.withRenderingMode(.alwaysOriginal)
        // Do any additional setup after loading the view.
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

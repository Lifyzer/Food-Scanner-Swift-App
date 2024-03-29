//
//  HomeVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class HomeTabVC: UITabBarController {
    static var sharedHomeTabVC: HomeTabVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        HomeTabVC.sharedHomeTabVC = self
        HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
    }
}
extension HomeTabVC: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.items?[0] == item {
            self.selectedIndex = 0
        }else if tabBar.items?[1] == item {
            self.selectedIndex = 1
        }else if tabBar.items?[2] == item {
            self.selectedIndex = 2
        }
    }
}

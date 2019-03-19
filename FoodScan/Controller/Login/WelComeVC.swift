//
//  WelComeVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class WelComeVC: UIViewController {

    @IBOutlet var buttonLogin: UIButton!
    @IBOutlet var buttonCreateAccount: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - Buttons
    @IBAction func buttonSignInClicked(_ sender: Any) {
        pushViewController(Storyboard: StoryBoardLogin, ViewController: idLoginVC, animation: true)
    }
    
    @IBAction func buttonSignUpClicked(_ sender: Any) {
        pushViewController(Storyboard: StoryBoardLogin, ViewController: idRegistrationVC, animation: true)
    }
}

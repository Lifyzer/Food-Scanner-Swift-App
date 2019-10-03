//
//  PrivacyPolicyVC.swift
//  FoodScan
//
//  Created by C110 on 12/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController, WKUIDelegate {

     @IBOutlet var webView: WKWebView!


    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:PRIVACY_POLICY_URL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

    }

    //MARK: - Buttons
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }




}

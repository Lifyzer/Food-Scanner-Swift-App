//
//  ForgotPasswordVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON


class ForgotPasswordVC: UIViewController {
    @IBOutlet var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.setLeftPaddingPoints(10)
      
        // Do any additional setup after loading the view.
    }
    

    //MARK: - Buttons
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonSendClicked(_ sender: Any) {
        
        if ValidateField() {
            if Connectivity.isConnectedToInternet
            {
            
            showIndicator(view: view)
            let param:NSMutableDictionary = [
                WS_KEmail_id:self.txtEmail.text!,
                WS_KDevice_type:DEVICE_TYPE,
                WS_KAccess_key:DEFAULT_ACCESS_KEY,
                WS_KSecret_key:UserDefaults.standard.string(forKey: kTempToken) ?? ""]
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIForgotPassword, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
               self.hideIndicator(view: self.view)
                if response != nil
                {
                    let alert = UIAlertController(title: APPNAME, message: forget_password_success,preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: .default,
                                                  handler: {(_: UIAlertAction!) in
                                                    self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else {
                    showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                }
            })
            }
        }
        else
        {
            showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
        }
    }
    
    
    
    func ValidateField() -> Bool {
        if !txtEmail.text!.isValid(){
            showBanner(title: "", subTitle: please_enter_email, bannerStyle: .danger)
        }else if !txtEmail.text!.isValidEmail(){
            showBanner(title: "", subTitle: please_enter_valid_email, bannerStyle: .danger)
        }else {
            return true
        }
        return false
    }
}

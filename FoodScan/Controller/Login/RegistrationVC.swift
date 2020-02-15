//
//  RegistrationVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

var deselected = UIImage(named: "Deselected")
var selected = UIImage(named: "Selected")

class RegistrationVC: UIViewController {
    @IBOutlet var txtFullName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtCmfPassword: UITextField!
    @IBOutlet var buttonCreateAccount: UIButton!
    @IBOutlet weak var imgTOS: UIImageView!
    @IBOutlet weak var lblTOS: UILabel!

    @IBOutlet weak var btnAcceptTOS: UIButton!

    @IBOutlet weak var btnRegister: UIButton!
    var isAcceptTOS = false

    override func viewDidLoad() {
        super.viewDidLoad()
        btnAcceptTOS.setImage(selected, for: .selected)
        btnAcceptTOS.setImage(deselected, for: .normal)
        txtFullName.setLeftPaddingPoints(10)
        txtEmail.setLeftPaddingPoints(10)
        txtPassword.setLeftPaddingPoints(10)
        txtCmfPassword.setLeftPaddingPoints(10)
        btnRegister.isEnabled = false
        btnRegister.backgroundColor = UIColor(red: 85/255, green: 165/255, blue: 70/255, alpha: 1.0).withAlphaComponent(0.5)
    }

    @IBAction func btnAcceptTC(_ sender: Any) {
        btnAcceptTOS.isSelected = !btnAcceptTOS.isSelected
        if btnAcceptTOS.isSelected{
            isAcceptTOS = true
            btnRegister.isEnabled = true
            btnRegister.backgroundColor = UIColor(red: 85/255, green: 165/255, blue: 70/255, alpha: 1.0)
        }else{
            isAcceptTOS = false
            btnRegister.isEnabled = false
            btnRegister.backgroundColor = UIColor(red: 85/255, green: 165/255, blue: 70/255, alpha: 1.0).withAlphaComponent(0.5)
        }
    }

    //MARK: - Buttons
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonPrivacyLinkClicked(_ sender: Any) {
        self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idPrivacyPolicyVC, animation: true)
    }

    @IBAction func buttonSignUpClicked(_ sender: Any) {

        if ValidateField(){
            if Connectivity.isConnectedToInternet
            {
                showIndicator(view: view)
                let param:NSMutableDictionary = [
                        WS_KEmail_id:self.txtEmail.text!,
                        WS_KFirst_name:self.txtFullName.text!,
                        WS_KLast_name:"",
                        WS_KDevice_type:DEVICE_TYPE,
                        WS_KPassword:self.txtPassword.text!,
                        WS_KAccess_key:DEFAULT_ACCESS_KEY,
                        WS_KSecret_key:UserDefaults.standard.string(forKey: kTempToken) ?? ""]
                
                HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIRegistration, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                    self.hideIndicator(view: self.view)
                    if response != nil
                    {
                        UserDefaults.standard.set(JSON(response!)[WSKUserToken].string, forKey: kUserToken)
                        if JSON(response!)[WSKUser].array? .count != 0 {
                            APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
                            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: KUser)
                            UserDefaults.standard.set(APP_DELEGATE.objUser?.guid.asStringOrEmpty(), forKey: kUserGUID)
                            UserDefaults.standard.set(APP_DELEGATE.objUser?.userId.asStringOrEmpty(), forKey: kUserId)
                            self.getGUID ()
                        }
                    }else {
                        self.generateAlertWithOkButton(text: message!)
                    }
                })
            }
        }
        else
        {
            self.generateAlertWithOkButton(text: no_internet_connection)
        }
    }

    func getGUID()
    {
        let GUID = UserDefaults.standard.value(forKey: kUserGUID)
        let param : NSDictionary = ["guid": GUID.asStringOrEmpty()]
        if Connectivity.isConnectedToInternet
        {
            HttpRequestManager.sharedInstance.postJSONRequestSecurity(endpointurl: APItestEncryption, parameters: param as NSDictionary) { (response, error, message) in
                if (error == nil)
                {
                    if (response != nil && response is NSDictionary)
                    {
                        let dicResp = response as! NSDictionary
                        UserDefaults.standard.set(dicResp.value(forKey: kEncrypted), forKey: kEncrypted)
                        self.hideIndicator(view: self.view)
                        UserDefaults.standard.set(true, forKey: kLogIn)
                        self.pushViewController(Storyboard: StoryBoardMain, ViewController: idHomeTabVC, animation: false)
                        HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
                    }
                }
                self.hideIndicator(view: self.view)
            }
        }else{
            self.generateAlertWithOkButton(text: no_internet_connection)
        }
    }

    func ValidateField() -> Bool {
        if !txtFullName.text!.isValid() {
             self.generateAlertWithOkButton(text: please_enter_full_name)
        } else if !txtEmail.text!.isValid() {
             self.generateAlertWithOkButton(text: please_enter_email)
        } else if !txtEmail.text!.isValidEmail() {
             self.generateAlertWithOkButton(text: please_enter_valid_email)
        } else if !txtPassword.text!.isValid() {
             self.generateAlertWithOkButton(text: please_enter_password)
        } else if !txtCmfPassword.text!.isValid() {
             self.generateAlertWithOkButton(text: please_enter_confirm_password)
        } else if txtPassword.text != txtCmfPassword.text {
             self.generateAlertWithOkButton(text: password_and_confirmpass_is_different)
        } else if isAcceptTOS == false {
             self.generateAlertWithOkButton(text: Accept_Terms_conditions)
        } else {
            return true
        }
        return false
    }

}

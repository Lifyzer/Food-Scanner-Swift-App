//
//  RegistrationVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegistrationVC: UIViewController {
    @IBOutlet var txtFullName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtCmfPassword: UITextField!
    @IBOutlet var buttonCreateAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        txtFullName.setLeftPaddingPoints(10)
        txtEmail.setLeftPaddingPoints(10)
        txtPassword.setLeftPaddingPoints(10)
        txtCmfPassword.setLeftPaddingPoints(10)
        // Do any additional setup after loading the view.
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
                    UserDefaults.standard.set(true, forKey: kLogIn)
                    self.pushViewController(Storyboard: StoryBoardMain, ViewController: idHomeTabVC, animation: true)
                    if JSON(response!)[WSKUser].array? .count != 0 {
                        APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
                        UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: WSUSER)
                        UserDefaults.standard.set(APP_DELEGATE.objUser?.guid, forKey: kUserGUID)
                        UserDefaults.standard.set(APP_DELEGATE.objUser?.userId, forKey: kUserId)
                    }
                }else {
                    showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                }
                
           
            })
        }
    }
    
    func ValidateField() -> Bool {
        if !txtFullName.text!.isValid(){
            showBanner(title: "", subTitle: please_enter_full_name, bannerStyle: .danger)
        }
        if !txtEmail.text!.isValid(){
            showBanner(title: "", subTitle: please_enter_email, bannerStyle: .danger)
        }else if !txtEmail.text!.isValidEmail()  {
             showBanner(title: "", subTitle: please_enter_valid_email, bannerStyle: .danger)
        }else if !txtPassword.text!.isValid(){
            showBanner(title: "", subTitle: please_enter_password, bannerStyle: .danger)
        }else if !txtCmfPassword.text!.isValid(){
             showBanner(title: "", subTitle: please_enter_confirm_password, bannerStyle: .danger)
        }else if txtPassword.text != txtCmfPassword.text{
            showBanner(title: "", subTitle: password_and_confirmpass_is_different, bannerStyle: .danger)
        }else {
            return true
        
        }
        return false
    }
        
    

}

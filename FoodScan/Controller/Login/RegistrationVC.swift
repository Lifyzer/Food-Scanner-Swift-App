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
                    //                    UserDefaults.standard.set(true, forKey: kLogIn)
                    
                    if JSON(response!)[WSKUser].array? .count != 0 {
                        APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
                        UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: KUser)
                        UserDefaults.standard.set(APP_DELEGATE.objUser?.guid.asStringOrEmpty(), forKey: kUserGUID)
                        UserDefaults.standard.set(APP_DELEGATE.objUser?.userId.asStringOrEmpty(), forKey: kUserId)
                        
                        self.getGUID ()
                    }
                    
//                    UserDefaults.standard.set(JSON(response!)[WSKUserToken].string, forKey: kUserToken)
//                    UserDefaults.standard.set(true, forKey: kLogIn)
//                    self.pushViewController(Storyboard: StoryBoardMain, ViewController: idHomeTabVC, animation: true)
//                    if JSON(response!)[WSKUser].array? .count != 0 {
//                        APP_DELEGATE.objUser = JSON(response!)[WSKUser].array?.first?.to(type: WSUser.self) as? WSUser
//                        UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: WSUSER)
//                        UserDefaults.standard.set(APP_DELEGATE.objUser?.guid, forKey: kUserGUID)
//                        UserDefaults.standard.set(APP_DELEGATE.objUser?.userId, forKey: kUserId)
//                    }
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
    func getGUID(){
        
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
                        
                        //                    let storyBoard = UIStoryboard(name: StoryBoardMain, bundle: nil)
                        //                    let vc = storyBoard.instantiateViewController(withIdentifier: idHomeTabVC) as! HomeTabVC
                        //                    vc.selectedIndex = 1
                        //                    self.navigationController?.pushViewController(vc, animated: true)
                        
                        //                    HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
                        self.pushViewController(Storyboard: StoryBoardMain, ViewController: idHomeTabVC, animation: false)
                        HomeTabVC.sharedHomeTabVC?.selectedIndex = 1
                        
                    }
                }
                self.hideIndicator(view: self.view)
            }
        }
        else
        {
            showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
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

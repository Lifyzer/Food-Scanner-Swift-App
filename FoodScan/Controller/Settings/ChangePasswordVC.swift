//
//  ChangePasswordVC.swift
//  FoodScan
//
//  Created by C110 on 12/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet var txtCurrentPwd: UITextField!
    @IBOutlet var txtNewPwd: UITextField!
    @IBOutlet var txtConfirmPwd: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtCurrentPwd.setLeftPaddingPoints(10)
        txtNewPwd.setLeftPaddingPoints(10)
        txtConfirmPwd.setLeftPaddingPoints(10)
    }


    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonChangeClicked(_ sender: Any) {
        if ValidateField(){
            if Connectivity.isConnectedToInternet
            {
                showIndicator(view: view)
                let userToken = UserDefaults.standard.string(forKey: kTempToken)
                let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)

                let param:NSMutableDictionary = [
                    WS_KPassword:self.txtCurrentPwd.text!,
                    WS_KNew_password:self.txtNewPwd.text!,
                    WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                    WS_KAccess_key:DEFAULT_ACCESS_KEY,
                    WS_KSecret_key:userToken ?? ""]
                HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIChangePassword, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                    self.hideIndicator(view: self.view)
                    if response != nil
                    {
                        let alert = UIAlertController(title: APPNAME, message: password_change_success,preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: .default,
                                                      handler: {(_: UIAlertAction!) in
                                                        self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        self.generateAlertWithOkButton(text: message!)
//                        showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                    }
                })
            }
            else
            {
                self.generateAlertWithOkButton(text: no_internet_connection)
//                showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
            }
        }
    }

    func ValidateField() -> Bool {

        if !txtCurrentPwd.text!.isValid() {
            self.generateAlertWithOkButton(text: please_enter_current_password)
        } else if !txtNewPwd.text!.isValid() {
            self.generateAlertWithOkButton(text: please_enter_new_password)
        } else if !txtConfirmPwd.text!.isValid() {
            self.generateAlertWithOkButton(text: please_enter_confirm_password)
        } else if txtNewPwd.text != txtConfirmPwd.text {
            self.generateAlertWithOkButton(text: password_and_confirmpass_is_different)
        } else {
            return true
        }
        return false
    }

}

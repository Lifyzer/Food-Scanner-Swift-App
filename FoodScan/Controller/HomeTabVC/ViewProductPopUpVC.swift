//
//  ViewPoructPopUpVC.swift
//  FoodScan
//
//  Created by NC2-32 on 15/03/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

//import TesseractOCR
@objc protocol SelectTextDelegate {
    func scanFlag(flag:Int)
}

class ViewProductPopUpVC: UIViewController {

    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTextfield: UIView!
    @IBOutlet weak var txtProductName: UITextField!
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var btnViewProduct: UIButton!
    var productName = ""
    var delegate:SelectTextDelegate?
    var objUser: WSUser?
//    var productName = ""
    var param : NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtProductName.text = productName
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil
        {
            self.dismiss(animated: false) {
            self.delegate?.scanFlag(flag: 0)
            }
//            self.dismiss(animated: true, completion: nil)
        }
    }
    func checkLoginAlert(){
        if !UserDefaults.standard.bool(forKey: kLogIn){
            let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "LOGIN",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            
                                            IsScanWithLogin = true
                                            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            }))
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in
                
            }))
            
            param = [
                WS_KProduct_name:productName,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
            
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                self.param!.addEntries(from: data1)
            }
            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: param!, forKey: SCANNED_DETAILS)
            self.dismiss(animated: false) {
                self.delegate?.scanFlag(flag: 0)
                HomeTabVC.sharedHomeTabVC?.present(alert, animated: true, completion: nil)
            }
            
        }else {
            objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
            GetProductDetailsAPI()
           
        }
    }
    
    @IBAction func btnViewProduct(_ sender: Any) {
        if txtProductName.text != ""
        {
            productName = txtProductName.text!
//            GetProductDetailsAPI()
            
            checkLoginAlert()
            print(txtProductName.text)
        }
        else
        {
            showBanner(title: "", subTitle: please_enter_product_name, bannerStyle: .danger)
        }
       
    }
}
//MARK: Textfiled Method
extension ViewProductPopUpVC : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
//MARK: Textfiled Method
extension ViewProductPopUpVC
{
    func GetProductDetailsAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
    //        DEFAULT_ACCESS_KEY = encodeString
            let param:NSMutableDictionary = [
                WS_KProduct_name:productName,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
    //            WS_KAccess_key:DEFAULT_ACCESS_KEY,
    //            WS_KSecret_key:userToken ?? ""]
            
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            
            showIndicator(view: self.view)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetProductDetails, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil
                {
                    let objData = JSON(response!)[WS_KProduct]
                   let objProduct = objData.to(type: WSProduct.self) as! [WSProduct]
                    
                    self.dismiss(animated: false) {
                        self.delegate?.scanFlag(flag: 0)
                        HomeTabVC.sharedHomeTabVC?.selectedIndex = 0
                        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
                        vc.objProduct = objProduct[0]
                        HomeTabVC.sharedHomeTabVC?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else
                {
                    self.dismiss(animated: false) {
                        self.delegate?.scanFlag(flag: 0)
                        showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                    }
                }
            })
        }
        else
        {
            showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
        }
    }
}

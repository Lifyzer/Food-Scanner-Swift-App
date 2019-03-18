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
//    var productName = ""
    
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
    
    @IBAction func btnViewProduct(_ sender: Any) {
        if txtProductName.text != ""
        {
            productName = txtProductName.text!
            GetProductDetailsAPI()
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
        
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
//        DEFAULT_ACCESS_KEY = encodeString
        let param:NSMutableDictionary = [
            WS_KProduct_name:productName,
            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
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
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
    }
}

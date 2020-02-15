//
//  ViewPoructPopUpVC.swift
//  FoodScan
//
//  Created by NC2-32 on 15/03/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    var param : NSMutableDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        txtProductName.text = productName
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil{
            self.dismiss(animated: false) {
                self.delegate?.scanFlag(flag: 0)
            }
        }
    }
    func checkLoginAlert(){
        if !UserDefaults.standard.bool(forKey: kLogIn){
            param = [
                WS_KProduct_name:productName,
                WS_FLAG : 0]
            UserDefaults.standard.set(0, forKey: KScanOption)
            UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: param!, forKey: SCANNED_DETAILS)
                self.delegate?.scanFlag(flag: 0)
                IsScanWithLogin = true
        }else {
            objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
        }
        GetProductDetailsAPI()
    }

    @IBAction func btnViewProduct(_ sender: Any) {
        if txtProductName.text != ""{
            productName = txtProductName.text!
            productName = productName.trimmingCharacters(in: .whitespaces)
            checkLoginAlert()
        }else{
            generateAlertWithOkButton(text: please_enter_product_name)
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
            let param:NSMutableDictionary = [
                WS_KProduct_name:productName,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                WS_FLAG : 0]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            showIndicator(view: self.view)
            print("===== Scan Param ========",param)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetProductDetails, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil
                {
                    let objData = JSON(response!)[WS_KProduct]
                    let objProduct = objData.to(type: WSProduct.self) as! [WSProduct]
                    self.dismiss(animated: false) {
                        self.delegate?.scanFlag(flag: 0)
                        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
                        vc.objProduct = objProduct[0]
                        HomeTabVC.sharedHomeTabVC?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else
                {
                    self.dismiss(animated: false) {
                        self.delegate?.scanFlag(flag: 0)
                        HomeTabVC.sharedHomeTabVC?.navigationController?.generateAlertWithOkButton(text: message!)
                    } 
                }
            })
        }
        else
        {
            self.generateAlertWithOkButton(text: no_internet_connection)
        }
    }
}

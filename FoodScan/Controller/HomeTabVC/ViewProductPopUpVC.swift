//
//  ViewPoructPopUpVC.swift
//  FoodScan
//
//  Created by NC2-32 on 15/03/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

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
        print(txtProductName.text)
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

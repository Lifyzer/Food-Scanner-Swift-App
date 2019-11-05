//
//  AddReviewVC.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

enum AddReviewItems: Int {
    case productImage = 0
    case ProductDetails
    case reviewTitle
    case reviewDesc
    static var count: Int { return AddReviewItems.reviewDesc.rawValue + 1}
}
struct AddReviewData {
    var product_name = ""
    var product_image = ""
    var user_id = ""
    var product_id = ""
    var ratting = Double()
    var title = ""
    var desc = ""
    var is_testdata = ""
}

class AddReviewVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableAddReview: UITableView!
    
    var addReviewData = AddReviewData()
    var objProduct : WSProduct!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Button actions
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddReviewAction(_ sender: Any) {
        if ValidateField(){
            addReviewAPI()
        }
    }
    
}
//MARK: Functions
extension AddReviewVC
{
    func setupUI()
    {
        tableAddReview.register(tableAddReviewProductImageCell.nib, forCellReuseIdentifier: tableAddReviewProductImageCell.reuseIdentifier)
        tableAddReview.register(tableAddReviewProductDetailsCell.nib, forCellReuseIdentifier: tableAddReviewProductDetailsCell.reuseIdentifier)
        tableAddReview.register(tableAddReviewTitleCell.nib, forCellReuseIdentifier: tableAddReviewTitleCell.reuseIdentifier)
        tableAddReview.register(tableAddReviewDescCell.nib, forCellReuseIdentifier: tableAddReviewDescCell.reuseIdentifier)
        addReviewData.product_image = objProduct.productImage.asStringOrEmpty()
        addReviewData.product_name = objProduct.productName.asStringOrEmpty()
    }

    @objc func textfieldEditingChanged(textfield : UITextField)
    {
        switch AddReviewItems.init(rawValue:textfield.tag)! {
        
        case .productImage,.ProductDetails,.reviewDesc:
            break
        case .reviewTitle:
            addReviewData.title = textfield.text!
        }
    }
    func ValidateField() -> Bool {
        if self.addReviewData.ratting == 0{
            showBanner(title: "", subTitle: please_select_ratting, bannerStyle: .danger)
        }else if !addReviewData.title.isValid() {
            showBanner(title: "", subTitle: please_enter_review_title, bannerStyle: .danger)
        }else if !addReviewData.desc.isValid() {
            showBanner(title: "", subTitle: please_enter_review_desc, bannerStyle: .danger)
        }else{
            return true
        }
        return false
    }
}
 //MARK: Tableview Method
extension AddReviewVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddReviewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch AddReviewItems.init(rawValue:row)! {
        case .productImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewProductImageCell.reuseIdentifier, for: indexPath) as! tableAddReviewProductImageCell
            if addReviewData.product_image != ""{
                cell.imgFood.sd_setImage(with: URL(string: addReviewData.product_image), placeholderImage: UIImage(named: "food_place_holder"))
            }else{
                cell.imgFood.image = UIImage(named: "food_place_holder")
            }
            
            return cell
        case .ProductDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewProductDetailsCell.reuseIdentifier, for: indexPath) as! tableAddReviewProductDetailsCell
            cell.viewRatting.settings.fillMode = .half
            cell.viewRatting.settings.minTouchRating = 0
            cell.lblTitle.text = objProduct.productName.asStringOrEmpty()
            cell.lblSubTitle.text  = ""
            if self.addReviewData.ratting == 0
            {
                self.addReviewData.ratting = cell.viewRatting.rating
            }
            cell.viewRatting.didFinishTouchingCosmos = { rating in
                self.addReviewData.ratting = rating
            }
            return cell
        case .reviewTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewTitleCell.reuseIdentifier, for: indexPath) as! tableAddReviewTitleCell
            cell.txtTitle.text = addReviewData.title
            cell.txtTitle.tag = row
            cell.txtTitle.attributedPlaceholder = NSAttributedString(string: add_review_title_placeholder,attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            cell.txtTitle.addTarget(self, action: #selector(textfieldEditingChanged(textfield:)), for: .editingChanged)
            return cell
        case .reviewDesc:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewDescCell.reuseIdentifier, for: indexPath) as! tableAddReviewDescCell
            cell.txtDescription.delegate = self
            if addReviewData.desc == ""{
                 cell.txtDescription.text = add_review_desc_placeholder
            }
            else{
                 cell.txtDescription.text = addReviewData.desc
            }
           
           
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch AddReviewItems.init(rawValue:row)! {
        case .productImage:
            return tableView.frame.height/3.5
        case .ProductDetails,.reviewTitle,.reviewDesc:
            return UITableView.automaticDimension
        }
    }
    
}

//MARK: TextView Method
extension AddReviewVC: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text != "" && addReviewData.desc == ""{
            textView.text = addReviewData.desc
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text != ""{
            addReviewData.desc = textView.text
            textView.textColor = UIColor.darkGray
            UIView.performWithoutAnimation {
                self.tableAddReview.beginUpdates()
                self.tableAddReview.endUpdates()
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""
        {
            addReviewData.desc = ""
            textView.text = add_review_desc_placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
//MARK: API Related stuff
extension AddReviewVC
{
    func addReviewAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            let param:NSMutableDictionary = [WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                                             WS_KProduct_id:objProduct.productId.asStringOrEmpty(),
                                             WS_RATTING: addReviewData.ratting,
                                             WS_TITLE:addReviewData.title,
                                             WS_DESC:addReviewData.desc,
                                             WS_IS_TEST: IS_TESTDATA]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            print("===== Add Review Param =======",param)
            
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddReview, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
               
                if response != nil
                {
                    self.navigationController?.popViewController(animated: true)
                    
                }else {
                   
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .error, TARGET: self)
                }
               
            })
        }
        else
        {
            SHOW_ALERT_VIEW(TITLE: "", DESC: no_internet_connection, STATUS: .error, TARGET: self)
        }
    }
}

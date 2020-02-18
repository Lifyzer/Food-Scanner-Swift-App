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
    case productDetails
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
    var desc = String()
    var is_testdata = ""
}
@objc protocol AddReviewDelegate {
    func willShowRatePopup(flag:Bool)
}

class AddReviewVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableAddReview: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    var addReviewData = AddReviewData()
    var objProduct : WSProduct!
    var isEditReview = false
    var objUserReview : UserReview?
    var btnSubmitText = "Submit"
    var btnUpdateText = "Update"
    var lblSubmitText = "Add Review"
    var lblUpdateText = "Edit Review"
    var delegate:AddReviewDelegate?

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
            if isEditReview{
                editReviewAPI()
            }else{
                addReviewAPI()
            }
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
        if isEditReview{
            setupUserEditReviewData()
        }else{
            lblTitle.text = lblSubmitText
            btnSubmit.setTitle(btnSubmitText, for: .normal)
        }
    }
    func setupUserEditReviewData()
    {
        lblTitle.text = lblUpdateText
        btnSubmit.setTitle(btnUpdateText, for: .normal)
        addReviewData.title = objUserReview!.title.asStringOrEmpty()
        addReviewData.desc = objUserReview!.descriptionValue.asStringOrEmpty()
        if let ratting = objUserReview!.ratting{
            addReviewData.ratting = Double(ratting)!
        }else{
            addReviewData.ratting = 0.0
        }
        tableAddReview.reloadData()
    }
    
    func ValidateField() -> Bool {
        if self.addReviewData.ratting == 0.0{
            showBanner(title: "", subTitle: please_select_ratting, bannerStyle: .danger)
        } else {
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
        case .productDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewProductDetailsCell.reuseIdentifier, for: indexPath) as! tableAddReviewProductDetailsCell
            cell.viewRatting.settings.fillMode = .half
            cell.viewRatting.settings.minTouchRating = 0
            cell.lblTitle.text = objProduct.productName.asStringOrEmpty()
            cell.lblSubTitle.text  = ""
            cell.viewRatting.rating = self.addReviewData.ratting
            cell.viewRatting.didFinishTouchingCosmos = { rating in
                self.addReviewData.ratting = rating
                cell.viewRatting.rating = self.addReviewData.ratting
            }
            return cell
        case .reviewDesc:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewDescCell.reuseIdentifier, for: indexPath) as! tableAddReviewDescCell
            cell.txtDescription.delegate = self
            if addReviewData.desc == ""{
                cell.txtDescription.text = add_review_desc_placeholder
                cell.txtDescription.textColor = UIColor.lightGray
            }else{
                cell.txtDescription.text = addReviewData.desc
                cell.txtDescription.textColor = UIColor.darkGray
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch AddReviewItems.init(rawValue:row)! {
        case .productImage:
            return tableView.frame.height/3.5
        case .productDetails,.reviewDesc:
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
        print("DESC",textView.text)
        if textView.text == ""
        {
            addReviewData.desc = ""
            textView.text = add_review_desc_placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}

extension String {
    var jsonStringRedecoded: String? {
        let data = ("\""+self+"\"").data(using: .utf8)!
        let result = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
        return result
    }
}
//MARK: API Related stuff
extension AddReviewVC
{
   
    func addReviewAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            self.showIndicator(view: self.view)
            var product_id = ""
            if let pid = objProduct.productId{
                if pid != ""{
                     product_id = pid
                }else{
                    if let id = objProduct.id{
                        if id != ""{
                             product_id = id
                        }
                    }
                }
            }
            else{
                if let id = objProduct.id{
                    if id != ""{
                         product_id = id
                    }
                }
            }
            let param:NSMutableDictionary = [WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                                             WS_KProduct_id:product_id,
                                             WS_RATTING: addReviewData.ratting,
                                             WS_DESC:addReviewData.desc,
                                             WS_IS_TEST: IS_TESTDATA]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            print("===== Add Review Param =======",param)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddReview, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil {
                    self.navigationController?.popViewController(animated: true)
                    let is_rate = JSON(response!)["is_rate"]
                    if is_rate == true {
                        self.delegate?.willShowRatePopup(flag: true)
                    }
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
    
    func editReviewAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            self.showIndicator(view: self.view)
            
            var param:[String:Any] = [WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                                      WS_REVIEWID : objUserReview?.id.asStringOrEmpty() ?? "",
                                             WS_RATTING: addReviewData.ratting,
                                             WS_DESC:addReviewData.desc,
                                             WS_IS_TEST: IS_TESTDATA]
            
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                for i in data1
                {
                    param.updateValue(i.value, forKey: i.key as! String)
                }
                //param.addEntries(from: data1)
            }
            print("===== Edit Review Param =======",param)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIEditReview, parameters: param as NSDictionary, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil {
                    self.isEditReview = false
                    self.navigationController?.popViewController(animated: true)
                    let is_rate = JSON(response!)["is_rate"]
                    if is_rate == true {
                        self.delegate?.willShowRatePopup(flag: true)
                    }
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

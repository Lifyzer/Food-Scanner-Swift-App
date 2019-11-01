//
//  AddReviewVC.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit


enum AddReviewItems: Int {
    case productImage = 0
    case ProductDetails
    case reviewTitle
    case reviewDesc
    static var count: Int { return AddReviewItems.reviewDesc.rawValue + 1}
}
struct AddReviewData {
    var user_id = ""
    var product_id = ""
    var ratting = 0
    var title = ""
    var desc = ""
    var is_testdata = ""
}

class AddReviewVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableAddReview: UITableView!
    
    var addReviewData = AddReviewData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Button actions
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddReviewAction(_ sender: Any) {
        
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
            return cell
        case .ProductDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewProductDetailsCell.reuseIdentifier, for: indexPath) as! tableAddReviewProductDetailsCell
            return cell
        case .reviewTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewTitleCell.reuseIdentifier, for: indexPath) as! tableAddReviewTitleCell
            cell.txtTitle.text = addReviewData.title
            cell.txtTitle.placeholder = add_review_title_placeholder
            cell.txtTitle.addTarget(self, action: #selector(textfieldEditingChanged(textfield:)), for: .editingChanged)
            return cell
        case .reviewDesc:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAddReviewDescCell.reuseIdentifier, for: indexPath) as! tableAddReviewDescCell
            cell.txtDescription.delegate = self
            if addReviewData.desc == ""
            {
                 cell.txtDescription.text = addReviewData.desc
            }
            else
            {
                 cell.txtDescription.text = add_review_desc_placeholder
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
extension AddReviewVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView)
    {
        if textView.text != ""{
            addReviewData.desc = textView.text
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
        }
    }
}

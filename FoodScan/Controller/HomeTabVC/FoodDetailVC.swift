//
//  FoodDetailVC.swift
//  FoodScan
//
//  Created by C110 on 16/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import Cosmos

let iDtableFoodCell = "tableFoodCell"
let IMG_FAV = UIImage(named: "unfav_white_icon")
let IMG_UNFAV = UIImage(named: "fav_white_icon")


enum ReviewItems: Int {
    case userReview = 0
    case custReviews
    case reviewList
    static var count: Int { return ReviewItems.reviewList.rawValue + 1}
}

class FoodDetailVC: UIViewController {
    @IBOutlet var tableDetails: UITableView!

    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet var lblProduct: UILabel!
    @IBOutlet var btnFav: UIButton!
    @IBOutlet var btnCategory: UIButton!
    @IBOutlet var vwHeader : UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableProductDetails: UITableView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnAddReview: UIButton!
    @IBOutlet weak var tableReview: UITableView!
    @IBOutlet weak var lblTotalReviews: UILabel!
    
    @IBOutlet weak var scrollWidth: NSLayoutConstraint!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tableContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableProductdetailsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewRatting: CosmosView!
    
    var objProduct : WSProduct!
    var arrDetails : NSMutableArray = NSMutableArray()
    var arrTitle : NSMutableArray = NSMutableArray()
    var arrImages : [UIImage] = [UIImage]()
    var arrReviewList : NSMutableArray = NSMutableArray()
    var isUserReview = true

    override func viewDidLoad() {
        super.viewDidLoad()
        SetFoodDetails()
        setupUI()

    }
    enum SubDetailsItems: Int {
        case Protein=0 , Sugar, Salt, Ingredients, Fat, Calories, SaturatedFats, Carbohydrate, DietaryFiber
        case totalCount = 9
    }
    //MARK: Functions
    func SetFoodDetails() {
        btnFav.layer.cornerRadius = btnFav.frame.height / 2
        lblProduct.text = objProduct.productName
        let isHealthy : String = objProduct.isHealthy ?? ""
        if isHealthy != "" && isHealthy.count > 0{
            if isHealthy == "0" {
                btnCategory.setTitle("\(Poor)", for: .normal)
                btnCategory.setTitleColor(UIColor(red:  230/255, green: 0/255, blue: 20/255, alpha: 1.0), for: .normal)
                btnCategory.setImage(UIImage(named: "dot_red_small"), for: .normal)
            }else {
                btnCategory.setTitle("Excellent", for: .normal)
                btnCategory.setTitleColor(UIColor(red:  85/255, green: 165/255, blue: 70/255, alpha: 1.0), for: .normal)
                btnCategory.setImage(UIImage(named: "dot_green_small"), for: .normal)
            }
        }
        let isFav = objProduct?.isFavourite.aIntOrEmpty()
        if isFav == 0{
            btnFav.setImage(UIImage(named: "unfav_white_icon"), for: .normal)
        }else if isFav == 1{
            btnFav.setImage(UIImage(named: "fav_white_icon"), for: .normal)
        }
        else
        {
            btnFav.setImage(UIImage(named: "unfav_white_icon"), for: .normal)
        }
    }

    func setupUI()
    {
        tableReview.register(tableReviewCell.nib, forCellReuseIdentifier: tableReviewCell.reuseIdentifier)
        tableReview.register(tableCustomerReviewCell.nib, forCellReuseIdentifier: tableCustomerReviewCell.reuseIdentifier)
        tableReview.register(tableUserReviewCell.nib, forCellReuseIdentifier: tableUserReviewCell.reuseIdentifier)

        btnFav.setImage(IMG_UNFAV, for: .normal)
        btnFav.setImage(IMG_FAV, for: .selected)
        if objProduct.isFavourite.asStringOrEmpty() == "0"{
            btnFav.isSelected = false //0
        }else if objProduct.isFavourite.asStringOrEmpty() == "1"{
            btnFav.isSelected = true//1
        }else{
            btnFav.isSelected = false
        }
        
        let imageURL = URL(string: objProduct.productImage ?? "")
        if imageURL != nil{
            imgProduct.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "food_place_holder"))
        }else{
            imgProduct.image = UIImage(named: "food_place_holder")
        }
        
        let objFood = objProduct
        CheckDetails(string: objFood?.protein, key: "Protein",img: "Protein")
        CheckDetails(string: objFood?.sugar, key: "Sugar",img: "Sugar")
        CheckDetails(string: objFood?.salt, key: "Salt",img: "Salt")
        CheckDetails(string: objFood?.ingredients, key: "Ingredients",img: "Ingredients")
        CheckDetails(string: objFood?.fatAmount, key: "Fat",img: "Fat")
        CheckDetails(string: objFood?.calories, key: "Calories",img: "Calories")
        CheckDetails(string: objFood?.saturatedFats, key: "Saturated Fats",img: "SaturatedFats")
        CheckDetails(string: objFood?.carbohydrate, key: "Carbohydrate",img: "Carbohydrate")
        CheckDetails(string: objFood?.dietaryFiber, key: "Dietary Fiber",img: "DietaryFiber")

        viewRatting.settings.updateOnTouch = false
        viewRatting.settings.fillMode = .half
        
        let avgReview = objProduct.avgReview
        if let avg = avgReview{
            viewRatting.rating = Double(avg)!
        }
        let totalReview = objProduct.totalReview
        if let reviews = totalReview{
           
            lblTotalReviews.text = Int(reviews)?.withCommas()
        }
        else
        {
            lblTotalReviews.text = ""
        }
        
        
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.viewRatting.addGestureRecognizer(tapGesture)
        
        // Set scrollview
        scrollWidth.constant = self.view.frame.width
        self.tableProductDetails.layoutIfNeeded()
        self.tableReview.layoutIfNeeded()
        self.vwHeader.layoutIfNeeded()
        self.tableProductdetailsHeight.constant = self.tableProductDetails.contentSize.height
        self.tableReviewHeight.constant = self.tableReview.contentSize.height
        contentHeight.constant = self.tableProductDetails.contentSize.height + vwHeader.frame.height + 40 + self.tableReview.contentSize.height
        tableProductDetails.tableFooterView = UIView()
        self.view.layoutIfNeeded()
        
    }

    @objc func tapAction()
    {
         self.scrollView.scrollToView(view: self.tableReview, animated: true)
    }
    func CheckDetails(string:String?,key:String,img:String){
        if (string.asStringOrEmpty() != "" && (string.asStringOrEmpty()) != "0")
        {
            arrTitle.add(key)
            arrDetails.add(string.asStringOrEmpty())
            arrImages.append(UIImage(named: img)!)
        }
    }

    
    func apicall(){
        if objProduct.isFavourite.aIntOrEmpty() == 0
        {
            objProduct.isFavourite = 1
        }
        else if objProduct.isFavourite.aIntOrEmpty() == 1
        {
            objProduct.isFavourite = 0
        }
        else
        {
            objProduct.isFavourite = 1
        }
    }

    func checkLoginAlert() -> Bool{
         if UserDefaults.standard.bool(forKey: kLogIn){
            return true
               // self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
        }else {
          return false
       }
    }
    @objc func shareFoodDetails()
    {
        let text = "Hey 🤗\n I just scanned \(objProduct.productName.asStringOrEmpty()) thanks “Lifyzer app”.\nSee what unbelievable things I found about it. It literally blows my mind! 😮\n\nP.S. I like you. You are my friend after all! Wouldn’t it be silly to get cancer just because of garbage food?\n\nScan your foods right now and see what you REALLY eat! 🥘\n —- \n🎯"
        let link = URL(string: "https://get.lifyzer.com")!

        let shareAll = [text ,link] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        print("Share product details")
    }
    
    //MARK: Button actions
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddReviewAction(_ sender: Any) {
        //Scroll to review list
//        self.scrollView.scrollToView(view: self.tableReview, animated: true)
        
        //Redirect to add revie screen
        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
        vc.objProduct = self.objProduct
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnShare(_ sender: Any) {
        shareFoodDetails()
    }

    @IBAction func btnFavourite(_ sender: UIButton) {

        if checkLoginAlert()
        {
            sender.isSelected = !sender.isSelected
            if sender.isSelected{
                btnFav.setImage(IMG_FAV, for: .normal)
            } else{
                btnFav.setImage(IMG_UNFAV, for: .normal)
            }
            
            if objProduct.isFavourite.asStringOrEmpty() == "0"{
                AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
            }else if objProduct.isFavourite.asStringOrEmpty() == "1"{
                AddRemoveFromFavouriteAPI(isFavourite : "0", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
            }else{
                AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
            }
        }
        else
        {
            let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "LOGIN",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            }))
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK:- Table - Delegate - DataSource
extension FoodDetailVC: UITableViewDelegate,UITableViewDataSource {

    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableReview
        {
            if isUserReview
            {
                return 5 + ReviewItems.count
            }
            return 5 + (ReviewItems.count - 1)
        }
        return arrDetails.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableReview
        {
            return UITableView.automaticDimension
        }
        let objTitle = arrTitle[indexPath.row]
        if "\(objTitle)" == "Ingredients"
        {
            return UITableView.automaticDimension
        }
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if tableView == tableReview
        {
            if isUserReview && row == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableUserReviewCell.reuseIdentifier, for: indexPath) as! tableUserReviewCell
//                cell.lblTitle.text = "User Reviww"
                return cell
            }
            else if !isUserReview && row == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableCustomerReviewCell.reuseIdentifier, for: indexPath) as! tableCustomerReviewCell
                cell.lblTitle.text = "Customer Reviww"
                return cell
            }
            else if isUserReview && row == 1
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableCustomerReviewCell.reuseIdentifier, for: indexPath) as! tableCustomerReviewCell
                cell.lblTitle.text = "Customer Reviww"
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableReviewCell.reuseIdentifier, for: indexPath) as! tableReviewCell
                return cell
            }
        }
        let objTitle = arrTitle[indexPath.row]
        let objDetails = arrDetails[indexPath.row]
        let objImg = arrImages[indexPath.row]

        if "\(objTitle)" != "Ingredients"
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "food_details_cell1", for: indexPath) as! tableFoodCell
            cell.selectionStyle = .none
             cell.imgFood.setImage(objImg, for: .normal)
            cell.productName.text = "\(objTitle)"
            cell.productType.setTitle("\(objDetails)", for: .normal)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "food_details_cell", for: indexPath) as! tableFoodCell
            cell.selectionStyle = .none
             cell.imgFood.setImage(objImg, for: .normal)
            cell.productName.text = "\(objTitle)"
            cell.productType.setTitle("", for: .normal)
             cell.productCategory.text = "\(objDetails)"
            return cell
        }
    }

}
//MARK: API related stuff
extension FoodDetailVC
{
//    func AddRemoveFromFavouriteAPI(isFavourite : String)
//    {
//        let userToken = UserDefaults.standard.string(forKey: kTempToken)
//        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
//        let param:NSMutableDictionary = [
//            WS_KProduct_id:objProduct.id.asStringOrEmpty(),
//            WS_KIs_favourite:isFavourite,
//            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
//            WS_KAccess_key:DEFAULT_ACCESS_KEY,
//            WS_KSecret_key:userToken ?? ""]
//        showIndicator(view: self.view)
//        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddToFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
//            self.hideIndicator(view: self.view)
//            if response != nil
//            {
//                showBanner(title: "", subTitle: message!, bannerStyle:.danger)
//            }else {
//                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
//            }
//        })
//    }
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
}
extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

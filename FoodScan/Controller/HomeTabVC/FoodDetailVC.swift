//
//  FoodDetailVC.swift
//  FoodScan
//
//  Created by C110 on 16/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import Cosmos
import Popover
import SwiftyJSON

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
    var offSet : Int = 0
    var noOfRecords  = REQ_NO_OF_RECORD
    var arrUserReview : [UserReview] = [UserReview]()
    var arrCustReview : [CustomerReview] = [CustomerReview]()
    var objReview:WSReview?
    

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
        
        setupScrollview()
        
        self.tableReview.isHidden = true
        self.getReviewListAPI(isLoader:true)
    }

    @objc func setupScrollview()
    {
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
        if objProduct.isFavourite.aIntOrEmpty() == 0{
            objProduct.isFavourite = 1
        }else if objProduct.isFavourite.aIntOrEmpty() == 1{
            objProduct.isFavourite = 0
        }else{
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
    @objc func redirectToaddReview()
    {
        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
        vc.objProduct = self.objProduct
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func loadMoreRequest()
    {
            self.offSet = arrCustReview.count //offSet +
            getReviewListAPI(isLoader: false)
    }
    
  
    //MARK: Button actions
      @objc func btnMoreActionOnReview(sender:UIButton)
      {
            //Show popup for edit and delete review => NOTE : used popover library for this
            let arr = Bundle.main.loadNibNamed(tableEditReviewCell.reuseIdentifier, owner: nil, options: nil)
            let appView = arr?.first as! tableEditReviewCell
//            appView.frame = CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y, width:150, height:90)
            appView.btnEdit.addTarget(self, action: #selector(btnEditReview(sender:)), for: .touchUpInside)
            appView.btnDelete.addTarget(self, action: #selector(btnDeleteReview), for: .touchUpInside)
            let options = [.type(.auto),
                           .animationIn(0.3),
                           .blackOverlayColor(UIColor.black.withAlphaComponent(0.4))] as [PopoverOption]
            let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
            popover.show(appView.contentView, fromView: sender)
            
        }
        @objc func btnEditReview(sender:UIButton)
        {
            print("===Edit Review===")

    //       let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
    //        vc.objProduct = self.objProduct
    //        vc.isEditReview = true
    //        self.navigationController?.pushViewController(vc, animated: true)
        }
        @objc func btnDeleteReview(sender:UIButton)
        {
          print("===Delete Review===")
        }
        
    
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
            if arrUserReview.count > 0 && arrCustReview.count > 0{
                 return arrUserReview.count + arrCustReview.count + 1
            }else if arrUserReview.count == 0 && arrCustReview.count > 0 {
                return arrCustReview.count + 1
            }else{
                return 0
            }
//            if isUserReview{
//                if arrUserReview.count > 0{
//                    return arrUserReview.count + arrCustReview.count + 1 //1 + ReviewItems.count
//                }
//                return 0
//            }
//            else if arrCustReview.count > 0{
//                return arrCustReview.count + (ReviewItems.count - 1)
//            }else{
//                return 0
//            }
            
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
                let objUserReview = arrUserReview[0]
                let cell = tableView.dequeueReusableCell(withIdentifier: tableUserReviewCell.reuseIdentifier, for: indexPath) as! tableUserReviewCell
                let userName = objUserReview.firstName.asStringOrEmpty() + " " + objUserReview.lastName.asStringOrEmpty()
                cell.lblReviewUserName.text = userName
                if let ratting = objUserReview.ratting{
                   cell.viewRatting.rating = Double(ratting)!
                }else
                {
                    cell.viewRatting.rating = 0.0
                }
                cell.lblReviewDate.text = objUserReview.modifiedDate.asStringOrEmpty()
                cell.lblReviewTime.text = "12.00 pm"
                cell.lblReviewTitle.text = objUserReview.title.asStringOrEmpty()
                cell.lblReviewDescription.text = objUserReview.descriptionValue.asStringOrEmpty()
                
                
                cell.btnMore.addTarget(self, action: #selector(btnMoreActionOnReview), for: .touchUpInside)
                return cell
            }
            else if (!isUserReview && row == 0) || (isUserReview && row == 1)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableCustomerReviewCell.reuseIdentifier, for: indexPath) as! tableCustomerReviewCell
                if let ratting = self.objReview?.avgReview{
                    cell.viewRatting.rating = Double(ratting)!
                    cell.lblReviewDetails.text = "\(ratting) out of 5"
                }else{
                    cell.viewRatting.rating = 0.0
                    cell.lblReviewDetails.text = "0 out of 5"
                }
                let totalReview = objProduct.totalReview
                if let reviews = totalReview{
                   
                    cell.lblTotalReviews.text = Int(reviews)?.withCommas()
                }
                else
                {
                    cell.lblTotalReviews.text = ""
                }
                
                if isUserReview{
                    cell.btnWriteReview.isHidden = true
                }else{
                    cell.btnWriteReview.isHidden = false
                    cell.btnWriteReview.addTarget(self, action: #selector(redirectToaddReview), for: .touchUpInside)
                }
                return cell
            }
//            else if isUserReview && row == 1
//            {
//                let objCustReview = arrCust[indexPath.row]
//                let cell = tableView.dequeueReusableCell(withIdentifier: tableCustomerReviewCell.reuseIdentifier, for: indexPath) as! tableCustomerReviewCell
////                cell.lblTitle.text = "Customer Reviww"
//                return cell
//            }
            else
            {
                var objReview : CustomerReview?
                if isUserReview
                {
                    objReview = arrCustReview[indexPath.row - 2]
                }
                else
                {
                    objReview = arrCustReview[indexPath.row - 1]
                }
//                let objReview = arrCustReview[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: tableReviewCell.reuseIdentifier, for: indexPath) as! tableReviewCell
                let userName = (objReview?.firstName.asStringOrEmpty() ?? "") + " " + (objReview?.lastName.asStringOrEmpty() ?? "")
                cell.lblReviewUserName.text = userName
                if let ratting = objReview?.ratting{
                   cell.viewRatting.rating = Double(ratting)!
                }else
                {
                    cell.viewRatting.rating = 0.0
                }
                cell.lblReviewDate.text = objReview?.modifiedDate.asStringOrEmpty()
                cell.lblReviewTime.text = "12.00 pm"
                cell.lblReviewTitle.text = objReview?.title.asStringOrEmpty()
                cell.lblReviewDescription.text = objReview?.descriptionValue.asStringOrEmpty()
                
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
//MARK: Scrollview delegate
extension FoodDetailVC : UIScrollViewDelegate
{

    //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }
    //load more tableView data
    @objc func loadMore(sender: AnyObject?) {
        loadMoreRequest()
    }
}


//MARK: API related stuff
extension FoodDetailVC
{
    func getReviewListAPI(isLoader : Bool)
    {
        
        if Connectivity.isConnectedToInternet
        {
           if isLoader{
           showIndicator(view: self.view)}
           let param:NSMutableDictionary = [WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
                                            WS_KProduct_id:objProduct.productId.asStringOrEmpty(),
                                            WS_KFrom_index:offSet,
                                            WS_KTo_index:noOfRecords,
                                            WS_IS_TEST: IS_TESTDATA]
           includeSecurityCredentials {(data) in
               let data1 = data as! [AnyHashable : Any]
               param.addEntries(from: data1)
           }
           print("===== Review list Param =======",param)
           
           HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIReviewList, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
              
             if(isLoader){
                self.hideIndicator(view: self.view)}
            
               if response != nil
               {
                    self.tableReview.isHidden = false
                    let objData = JSON(response!)[WS_DATA]
                    let objUserReview = JSON(objData[WS_USER_REVIEW])
                    let objCustReview = JSON(objData[WS_CUST_REVIEW])
                
//                    let objReview  = objData.to(type: WSReview.self) as! WSReview
                    self.objReview = objData.to(type: WSReview.self) as? WSReview
                    let arrayUserReview  = objUserReview.to(type: UserReview.self) as! [UserReview]
                    let arrayCustReview  = objCustReview.to(type: CustomerReview.self) as! [CustomerReview]

                    self.arrUserReview = arrayUserReview
                    self.arrCustReview  = arrayCustReview
                
                     if arrayUserReview.count > 0{
                        self.isUserReview = true
                    }else{
                        self.isUserReview = false
                    }
                    if arrayCustReview.count > 0{
                        if self.offSet == 0 {
                            self.arrCustReview.removeAll()
                            self.arrCustReview = arrayCustReview
                        }else{
                            self.arrCustReview.append(contentsOf: arrayCustReview)
                        }
                        self.tableReview.loadControl?.endLoading()
                    }
                    self.tableReview.reloadData()
                    self.setupScrollview()
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
//========================================================================================
//MARK: UIScrollView extention => Scroll to review list
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
//MARK: Int extention => show reviews value with commas
extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

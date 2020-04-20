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
import UILoadControl

let iDtableFoodCell = "tableFoodCell"
let IMG_FAV = UIImage(named: "unfav_white_icon")
let IMG_UNFAV = UIImage(named: "fav_white_icon")
var CountryHeight = 55

enum ReviewItems: Int {
    case userReview = 0
    case custReviews
    case reviewList
    static var count: Int { return ReviewItems.reviewList.rawValue + 1}
}

enum SubDetailsItems: Int {
    case Protein=0 , Sugar, Salt, Ingredients, Fat, Calories, SaturatedFats, Carbohydrate, DietaryFiber
    case totalCount = 9
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
    @IBOutlet weak var tableReview: UITableView!
    @IBOutlet weak var lblTotalReviews: UILabel!
    @IBOutlet weak var viewRatting: CosmosView!
    @IBOutlet weak var viewGiveReview: UIView!
    @IBOutlet weak var btnGiveReview: UIButton!
    @IBOutlet weak var scrollWidth: NSLayoutConstraint!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tableProductdetailsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewGiveReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewWriteReview: UIView!
    
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
    var popover = Popover()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetFoodDetails()
        setupUI()

    }
                           
    override func viewWillAppear(_ animated: Bool) {
        self.tableReview.isHidden = true
        self.scrollView.scrollToTop(animated: false)
        self.offSet = 0
        self.getReviewListAPI(isLoader:false)
    }
    
    override func viewDidLayoutSubviews() {
        print("****REVIW TABLE UPDATING****")
        setupReviewTable()
        setupScrollview()
    }
    
  
    //MARK: Button actions
    @IBAction func btnGiveReviewAction(_ sender: Any) {
        //Redirect to add review screen
        if checkLoginAlert(){
            redirectToaddReviewScreen()
        }else{
          LoginAlert()
        }
    }
    
    @objc func btnMoreActionOnReview(sender:UIButton)
    {
        //Show popup for edit and delete review => NOTE : used popover library for this
        let arr = Bundle.main.loadNibNamed(tableEditReviewCell.reuseIdentifier, owner: nil, options: nil)
        let appView = arr?.first as! tableEditReviewCell
        appView.btnEdit.addTarget(self, action: #selector(btnEditReviewAction(sender:)), for: .touchUpInside)
        appView.btnDelete.addTarget(self, action: #selector(btnDeleteReviewAction(sender:)), for: .touchUpInside)
        let options = [.type(.auto),
                   .cornerRadius(5.0),
                   .animationIn(0.3),
                   .blackOverlayColor(UIColor.black.withAlphaComponent(0.4)),
                   .sideEdge(5.0)] as [PopoverOption]
        popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.show(appView.contentView, fromView: sender)
    }
    
    @objc func btnEditReviewAction(sender:UIButton)
    {
        print("===Edit Review===")
        popover.dismiss()
        popover.didDismissHandler = {
            let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
            vc.objProduct = self.objProduct
            vc.isEditReview = true
            vc.objUserReview = self.arrUserReview.first
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func btnDeleteReviewAction(sender:UIButton)
    {
        print("===Delete Review===")
        popover.dismiss()
        popover.didDismissHandler = {
            self.deleteReviewAPI()
        }
    }
    
    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddReviewAction(_ sender: Any) {
        //Redirect to add review screen
        if checkLoginAlert(){
            redirectToaddReviewScreen()
        }else{
           LoginAlert()
        }
    }
    
    @IBAction func btnShare(_ sender: Any) {
        shareFoodDetails()
    }
    
    @IBAction func btnFavourite(_ sender: UIButton) {
        if checkLoginAlert()
        {
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
//MARK: Functions
extension FoodDetailVC
{
    func LoginAlert()
    {
        let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "LOGIN",style: .default,handler: {(_: UIAlertAction!) in
                self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
       }))
       alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in
       }))
       self.present(alert, animated: true, completion: nil)
    }
    
    func SetShadowToButton()
    {
        self.viewWriteReview.layer.cornerRadius = 8.0
        self.btnGiveReview.layer.cornerRadius = 8.0
    }
    
    func setupReviewTable()
    {
        tableReview.reloadData()
        tableReview.layoutIfNeeded()
        tableReviewHeight.constant = tableReview.contentSize.height
    }
    
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
        let isFav = objProduct?.isFavourite.asStringOrEmpty()
        if isFav == "1"{
            btnFav.isSelected = true
        }else{
            btnFav.isSelected = false
        }
    }

    func setupUI()
    {
        SetShadowToButton()
        scrollView.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        scrollView.loadControl?.heightLimit = 0.0//100.0
        scrollView.loadControl?.isHidden = true
        scrollView.delegate = self
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
        setupRattingDetails()
        setupScrollview()
    }
    func setupRattingDetails()
    {
        let avgReview = objProduct.avgReview
        if let avg = avgReview{
            if avg != ""{
                 viewRatting.rating = Double(avg)!
            }else{
                viewRatting.rating = 0.0
            }
        }
        let totalReview = objProduct.totalReview
        if let reviews = totalReview{
            lblTotalReviews.text = Int(reviews)?.withCommas()
        }else{
            lblTotalReviews.text = ""
        }
        let userId = UserDefaults.standard.string(forKey: kUserId) ?? ""
        //Add Gesture on Rtting view => that will scroll to review list.
        if viewRatting.rating != 0.0 && userId != "" {
            self.viewRatting.settings.updateOnTouch = false
        }else if viewRatting.rating == 0.0 && userId != ""{
            self.viewRatting.settings.updateOnTouch = true
        }else{
            self.viewRatting.settings.updateOnTouch = false
        }
        
        viewRatting.didFinishTouchingCosmos = { rating in
            if totalReview != "0"{
                self.tapAction()
            }else{
                if self.checkLoginAlert(){
                         let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
                          vc.objProduct = self.objProduct
                          vc.addReviewData.ratting = self.viewRatting.rating
                          vc.delegate = self
                          self.viewRatting.rating = 0.0
                          self.navigationController?.pushViewController(vc, animated: true)
               }else{
                    self.LoginAlert()
               }
                
            }
        }
    }

    @objc func setupScrollview()
    {
        tableProductDetails.tableFooterView = UIView()
        self.view.layoutIfNeeded()
        scrollWidth.constant = self.view.frame.width
        self.tableProductdetailsHeight.constant = self.tableProductDetails.contentSize.height
        self.view.layoutIfNeeded()
    }
    func CountDateTime(dateString:String) -> (String,String)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let reviewDate = dateFormatter.string(from: stringToDate(dateString))
       
        dateFormatter.dateFormat = "hh:mm a"
        let reviewTime = dateFormatter.string(from: stringToDate(dateString))
        return (reviewDate,reviewTime)
    }
    @objc func tapAction()
    {
        UIView.animate(withDuration: 1.0, animations: {
            self.scrollView.scrollToView(view: self.tableReview, animated: false)
        })
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
        if objProduct.isFavourite.asStringOrEmpty() == "0"{
            objProduct.isFavourite = "1"
        }else if objProduct.isFavourite.asStringOrEmpty() == "1"{
            objProduct.isFavourite = "0"
        }else{
            objProduct.isFavourite = "1"
        }
        btnFav.isSelected = !btnFav.isSelected
    }

    func checkLoginAlert() -> Bool{
         if UserDefaults.standard.bool(forKey: kLogIn){
            return true
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
    }
    @objc func redirectToaddReviewScreen()
    {
        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idAddReviewVC) as! AddReviewVC
        vc.objProduct = self.objProduct
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func loadMoreRequest()
    {
        self.offSet = arrCustReview.count
        self.getReviewListAPI(isLoader: false)
    }
    
}


//MARK: Add review Delegate
extension FoodDetailVC: AddReviewDelegate{
    func willShowRatePopup(flag: Bool) {
        if flag{
            self.rateApp()
        }
    }
}


//MARK:- Table - Delegate - DataSource
extension FoodDetailVC: UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableReview
        {
            return 3
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableReview
        {
            if section == 0{
                return arrUserReview.count
            }else if section == 1{
                if arrCustReview.count > 0{
                    return 1
                }
                return 0
            }else{
                return arrCustReview.count
            }
        }
        return arrDetails.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableReview{
            return UITableView.automaticDimension
        }
        let objTitle = arrTitle[indexPath.row]
        if "\(objTitle)" == "Ingredients"{
            return UITableView.automaticDimension
        }
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if tableView == tableReview
        {
            if indexPath.section == 0
            {
                let objUserReview = arrUserReview[0]
                let cell = tableView.dequeueReusableCell(withIdentifier: tableUserReviewCell.reuseIdentifier, for: indexPath) as! tableUserReviewCell
                let userName = objUserReview.firstName.asStringOrEmpty() + " " + objUserReview.lastName.asStringOrEmpty()
                cell.lblReviewUserName.text = userName
                if let ratting = objUserReview.ratting{
                   cell.viewRatting.rating = Double(ratting)!
                }else{
                    cell.viewRatting.rating = 0.0
                }
                
                let reviewDateTime = CountDateTime(dateString: objUserReview.modifiedDate.asStringOrEmpty())
                cell.lblReviewDate.text = reviewDateTime.0
                cell.lblReviewTime.text =  reviewDateTime.1
                cell.lblReviewTitle.text = objUserReview.title.asStringOrEmpty()
                cell.lblReviewDescription.text = objUserReview.descriptionValue.asStringOrEmpty()
                cell.btnMore.addTarget(self, action: #selector(btnMoreActionOnReview), for: .touchUpInside)
                return cell
            }
            else if indexPath.section == 1
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: tableCustomerReviewCell.reuseIdentifier, for: indexPath) as! tableCustomerReviewCell
                if let ratting = self.objReview?.avgCustomerReview{
                    cell.viewRatting.rating = Double(ratting)!
                    cell.lblReviewDetails.text = "\(ratting) out of 5"
                }else{
                    cell.viewRatting.rating = 0.0
                    cell.lblReviewDetails.text = "0 out of 5"
                }
                let totalReview =  self.objReview?.totalCustomerReview
                if let reviews = totalReview{
                    let temp = Int(reviews)!
                    if temp > 1{
                        cell.lblTotalReviews.text = (Int(reviews)?.withCommas() ?? "") + " reviews"
                    }else{
                        cell.lblTotalReviews.text = (Int(reviews)?.withCommas() ?? "") + " review"
                    }
                }else{
                    cell.lblTotalReviews.text = ""
                }
                
                if isUserReview{
                    cell.btnWriteReview.isHidden = true
                }else{
                    cell.btnWriteReview.isHidden = false
                    cell.btnWriteReview.addTarget(self, action: #selector(redirectToaddReviewScreen), for: .touchUpInside)
                }
                return cell
            }
            else
            {
                var objReview : CustomerReview?
                objReview = arrCustReview[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: tableReviewCell.reuseIdentifier, for: indexPath) as! tableReviewCell
                let userName = (objReview?.firstName.asStringOrEmpty() ?? "") + " " + (objReview?.lastName.asStringOrEmpty() ?? "")
                cell.lblReviewUserName.text = userName
                if let ratting = objReview?.ratting{
                   cell.viewRatting.rating = Double(ratting)!
                }else{
                    cell.viewRatting.rating = 0.0
                }
                let reviewDateTime = CountDateTime(dateString: objReview!.modifiedDate.asStringOrEmpty())
                cell.lblReviewDate.text = reviewDateTime.0
                cell.lblReviewTime.text =  reviewDateTime.1
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
        self.scrollView.loadControl?.update()
    }
    //load more tableView data
    @objc func loadMore(sender: AnyObject?) {
        print("loadMoreRequest")
        loadMoreRequest()
    }
}

//MARK: API related stuff
extension FoodDetailVC
{
    func deleteReviewAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            self.showIndicator(view: self.view)
            let param:NSMutableDictionary = [WS_REVIEWID :arrUserReview.first?.id.asStringOrEmpty() ?? "",
                                             WS_IS_TEST: IS_TESTDATA]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            print("===== Edit Review Param =======",param)
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIDeleteReview, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                self.hideIndicator(view: self.view)
                if response != nil {
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
                    self.isUserReview = false
                    let totalReview = Int(self.objProduct.totalReview!)! - 1
                    let totalRatting = Float(self.objReview!.totalRatting.asStringOrEmpty())!.rounded(.down)
                    let userRatting = Float(self.arrUserReview.first!.ratting.asStringOrEmpty())!.rounded(.down)
                    let finalratting = totalRatting - userRatting
                    if finalratting != 0 && totalReview != 0
                    {
                        self.objProduct.avgReview = "\(finalratting/Float(totalReview))"
                        self.objProduct.totalReview = "\(totalReview)"
                    }
                    else
                    {
                        self.objProduct.avgReview = "0"
                        self.objProduct.totalReview = "0"
                    }
                    self.arrUserReview.removeAll()
                    self.setupRattingDetails()
                    self.tableReview.reloadData()
                    DispatchQueue.main.async {
                        self.setupReviewTable()
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
    func getReviewListAPI(isLoader : Bool)
    {
        if Connectivity.isConnectedToInternet
        {
           if isLoader{
            showIndicator(view: self.view)
            }
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
                self.scrollView.loadControl?.endLoading()
                if response != nil
                {
                    self.tableReview.isHidden = false
                    let objData = JSON(response!)[WS_DATA]
                    let objUserReview = JSON(objData[WS_USER_REVIEW])
                    let objCustReview = JSON(objData[WS_CUST_REVIEW])
                
                    self.objReview = objData.to(type: WSReview.self) as? WSReview
                    let arrayUserReview  = objUserReview.to(type: UserReview.self) as! [UserReview]
                    let arrayCustReview  = objCustReview.to(type: CustomerReview.self) as! [CustomerReview]

                    self.objProduct.avgReview = self.objReview?.avgReview.asStringOrEmpty()
                    self.objProduct.totalReview = self.objReview?.totalReview.asStringOrEmpty()
                    self.setupRattingDetails()
                    if arrayUserReview.count > 0{
                        self.arrUserReview.removeAll()
                        self.arrUserReview = arrayUserReview
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
                    }
                    if self.arrUserReview.count == 0 && self.arrCustReview.count == 0{
                        self.viewGiveReview.isHidden = false
                        self.viewGiveReviewHeight.constant = 100.0//54.0
                        self.btnGiveReview.isHidden = false
                    }else{
                        self.viewGiveReview.isHidden = true
                        self.viewGiveReviewHeight.constant = 0.0
                        self.btnGiveReview.isHidden = true
                    }
                    self.tableReview.reloadData()
                    DispatchQueue.main.async {
                        self.setupReviewTable()
                    }
               }else {
                if message != MESSAGE{
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .error, TARGET: self)
                }
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

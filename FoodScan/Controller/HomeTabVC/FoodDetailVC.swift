//
//  FoodDetailVC.swift
//  FoodScan
//
//  Created by C110 on 16/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
let iDtableFoodCell = "tableFoodCell"
let IMG_FAV = UIImage(named: "unfav_white_icon")
let IMG_UNFAV = UIImage(named: "fav_white_icon")

class FoodDetailVC: UIViewController {
    @IBOutlet var tableDetails: UITableView!
  
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet var lblProduct: UILabel!
    @IBOutlet var btnFav: UIButton!
    @IBOutlet var btnCategory: UIButton!
    @IBOutlet var vwHeader : UIView!
    var objProduct : WSProduct!
    var arrDetails : NSMutableArray = NSMutableArray()
    var arrTitle : NSMutableArray = NSMutableArray()
    var arrImages : [UIImage] = [UIImage]()
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollWidth: NSLayoutConstraint!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tableContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableProductDetails: UITableView!
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
//        tableDetails.tableHeaderView = vwHeader
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
    
    func setupUI(){
        btnFav.setImage(IMG_UNFAV, for: .normal)
        btnFav.setImage(IMG_FAV, for: .selected)
        if objProduct.isFavourite.asStringOrEmpty() == "0"
        {
            btnFav.isSelected = false //0
        }
        else if objProduct.isFavourite.asStringOrEmpty() == "1"
        {
            btnFav.isSelected = true//1
        }
        else
        {
            btnFav.isSelected = false
        }
        let imageURL = URL(string: objProduct.productImage ?? "")
        //        cell.imgFood.sd_setImage(with: imageURL,for:.normal)
        if imageURL != nil
        {
            imgProduct.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "food_place_holder"))
        }
        else
        {
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
        
        // Set scrollview
        scrollWidth.constant = self.view.frame.width
        self.tableProductDetails.layoutIfNeeded()
        self.vwHeader.layoutIfNeeded()
        contentHeight.constant = self.tableProductDetails.contentSize.height + vwHeader.frame.height + 40
        tableProductDetails.tableFooterView = UIView()
        self.view.layoutIfNeeded()
    }
    
    func CheckDetails(string:String?,key:String,img:String){
        if (string.asStringOrEmpty() != "" && (string.asStringOrEmpty()) != "0")
        {
            arrTitle.add(key)
            arrDetails.add(string.asStringOrEmpty())
            arrImages.append(UIImage(named: img)!)
        }
    }

    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func btnFavourite(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            btnFav.setImage(IMG_FAV, for: .normal)
        }
        else
        {
            btnFav.setImage(IMG_UNFAV, for: .normal)
        }
        
        if objProduct.isFavourite.asStringOrEmpty() == "0"
        {
            AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
        }
        else if objProduct.isFavourite.asStringOrEmpty() == "1"
        {
            AddRemoveFromFavouriteAPI(isFavourite : "0", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
        }
        else
        {
            AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:apicall)
        }
        
    }
}

//MARK:- Table - Delegate - DataSource
extension FoodDetailVC: UITableViewDelegate,UITableViewDataSource {
    
    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == tableProductDetails
//        {
//            return 1
//        }
        return arrDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableView == tableProductDetails
//        {
//            let ingreText = objProduct.ingredients.asStringOrEmpty()
//            var height:CGFloat = 0.0
//            if ingreText != ""
//            {
//                let lbl = UILabel()
//                lbl.text = ingreText
////                lbl.sizeToFit()
//                height = CGFloat(lbl.frame.height) + 50.0
//            }
//            let tableheight  = CGFloat(75 * (arrDetails.count - 1) + 40)
//            return CGFloat(tableheight + height)
//        }
        let objTitle = arrTitle[indexPath.row]
        if "\(objTitle)" == "Ingredients"
        {
            return UITableView.automaticDimension
        }
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

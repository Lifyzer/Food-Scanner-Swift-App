//
//  HistoryVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON
//import TesseractOCR



class HistoryVC: UIViewController {

    @IBOutlet var lblNoDataTitle: UILabel!
    @IBOutlet var lblNoDataMsg: UILabel!
    @IBOutlet var btnNoData: UIButton!
    
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet var buttonHistory: UIButton!
    @IBOutlet var vwFav: UIView!
    @IBOutlet var vwHistory: UIView!
    @IBOutlet var vwNoData: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableHistory: UITableView!
    @IBOutlet var tableFav: UITableView!
    
    
    var isFav: Bool = false
    var arrayFavFood = [WSProduct]()
    var arrayHistoryFood = [WSProduct]()
    var objUser: WSUser?
    var isLoadMore:Bool = false
    let refresher = UIRefreshControl()
    var offSet : Int = 0
    var noOfRecords  = REQ_NO_OF_RECORD
    var RemoveIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableHistory.tableFooterView = UIView()
        self.tableFav.tableFooterView = UIView()
        
        refresher.addTarget(self, action: #selector(initialRequest(_:)), for: .valueChanged)
        tableFav.refreshControl = refresher
        refresher.addTarget(self, action: #selector(initialRequest(_:)), for: .valueChanged)
        tableHistory.refreshControl = refresher
        
        if isFav{
             tableHistory.isHidden = true
             tableFav.isHidden = false
            if arrayFavFood.count == 0{
                ShowNoDataMessage()
                getFavFood(isLoader: true)
            }
        }else {
            tableHistory.isHidden = false
            tableFav.isHidden = true
            if arrayHistoryFood.count == 0{
                ShowNoDataMessage()
                getHistory(isLoader: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APP_DELEGATE.objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
    }
    
    func ShowNoDataMessage() {
        if isFav{
            lblNoDataTitle.text = "No Favourite Yet!"
            lblNoDataMsg.text = "Once you favourite any food, you will see them here"
            btnNoData.setImage(UIImage(named: "img_no_fav_data"), for: .normal)
            tableFav.isHidden = true
        }else {
            lblNoDataTitle.text = "No Data Available"
            lblNoDataMsg.text = "Once you scan any food, you will see them here"
            btnNoData.setImage(UIImage(named: "img_no_history_data"), for: .normal)
            tableHistory.isHidden = true
        }
        vwNoData.isHidden = false
    }
    
    func HideNoDataMessage() {
        if isFav{
            tableFav.isHidden = false
        }else {
            tableHistory.isHidden = false
        }
        vwNoData.isHidden = true
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //MARK: Functions
    @objc func btnFavourite(_ sender: UIButton) {
        let objProduct  = arrayFavFood[sender.tag]
        RemoveIndex = sender.tag
        if objProduct.isFavourite.asStringOrEmpty() == "0"
        {
            AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
        }
        else
        {
            AddRemoveFromFavouriteAPI(isFavourite : "0", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
        }
    }
    
    func AfterAPICall(){
        
        arrayFavFood.remove(at:RemoveIndex)
        tableFav.reloadData()
    }
    
     //MARK:- Button click
    @IBAction func buttonHistoryClicked(_ sender: Any) {
        self.setView(view: tableHistory , hidden: false)
        self.setView(view: tableFav , hidden: true)
        isFav = false
        vwHistory.isHidden = false
        vwFav.isHidden = true
        tableFav.isHidden = true
        tableHistory.isHidden = false
        if arrayHistoryFood.count == 0{
            ShowNoDataMessage()
            self.getHistory(isLoader: true)
        }else {
            HideNoDataMessage()
            tableHistory.reloadData()
        }
    }
    
    @IBAction func buttonFavClicked(_ sender: Any) {
        self.setView(view: tableHistory , hidden: true)
        self.setView(view: tableFav , hidden: false)
        isFav = true
        vwHistory.isHidden = true
        vwFav.isHidden = false
        tableFav.isHidden = false
        tableHistory.isHidden = true
        if arrayFavFood.count == 0{
            ShowNoDataMessage()
            self.getFavFood(isLoader: true)
        }else {
            HideNoDataMessage()
            tableHistory.reloadData()
        }
        
    }
    
    //MARK:- Webservice Call
    @objc private func initialRequest(_ sender: Any) {
        self.offSet = 0
        if isFav{
            self.getFavFood(isLoader: false)
        }else {
            self.getHistory(isLoader: false)
        }
        
    }
    
    func loadMoreRequest() {
        if isFav{
            self.offSet = offSet + arrayFavFood.count
            getFavFood(isLoader: false)
        }else {
            self.offSet = offSet + arrayHistoryFood.count
            getHistory(isLoader: false)
        }
    }
    
    func getFavFood(isLoader : Bool){
        if isLoader{
            showIndicator(view: self.view)}
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        let param:NSMutableDictionary = [
            WS_KTo_index:noOfRecords,
            WS_KFrom_index:offSet,
            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetAllUserFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            if(isLoader){
                self.hideIndicator(view: self.view)}
            if response != nil
            {
                let objData = JSON(response!)[WS_KProduct]
                let tempArray  = objData.to(type: WSProduct.self) as! [WSProduct]
                if tempArray.count > 0{
                    
                    self.arrayFavFood.append(contentsOf: tempArray)
                    self.tableFav.reloadData()
                }
                
                if(self.arrayFavFood.count == 0){
                    self.ShowNoDataMessage()
                }else {
                    self.HideNoDataMessage()
                    if isLoader {
                        self.tableFav.reloadData()
                    }
                }
                
                if self.isLoadMore{
                    self.isLoadMore = false
                    self.indicatorView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                self.refresher.endRefreshing()
            }else {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
        
    }
    
    func getHistory(isLoader : Bool){
        if isLoader{
            showIndicator(view: self.view)}
        let userToken = UserDefaults.standard.string(forKey: kUserToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        
        print("encode string : \(encodeString!)")
        
        let param:NSMutableDictionary = [
            WS_KTo_index:noOfRecords,
            WS_KFrom_index:offSet,
            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetUserHistory, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            if(isLoader){
                self.hideIndicator(view: self.view)}
            if response != nil
            {
                let objData = JSON(response!)[WS_KHistory]
                let tempArray  = objData.to(type: WSProduct.self) as! [WSProduct]
                if tempArray.count > 0{
                     self.arrayHistoryFood.append(contentsOf: tempArray)
                     self.tableHistory.reloadData()
                }
                if(self.arrayHistoryFood.count == 0){
                    self.ShowNoDataMessage()
                }else {
                    self.HideNoDataMessage()
                     if isLoader {
                        self.tableHistory.reloadData()
                    }
                }
                
                if self.isLoadMore{
                    self.isLoadMore = false
                    self.indicatorView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                self.refresher.endRefreshing()
            }else {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
    }
    
    func removeHistory(historyId : String, rowId :Int){
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        let param:NSMutableDictionary = [
            WS_KHistory_id:historyId,
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIRemoveProductFromHistory, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            if response != nil
            {
                showBanner(title: "", subTitle:"Product is successfully removed from History" , bannerStyle: .success)
                self.arrayHistoryFood.remove(at: rowId)
                if(self.arrayHistoryFood.count == 0){
                    self.ShowNoDataMessage()
                }else {
                    self.HideNoDataMessage()
                }
                self.tableHistory.reloadData()
            }else {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
    }
 
    func addRemoveFav(productId : String, rowId :Int, favStatus : String){
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        let param:NSMutableDictionary = [
            WS_KUser_id:objUser?.userId,
            WS_KProduct_id:productId,
            WS_KIs_favourite:favStatus,
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddToFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            if response != nil
            {
                if !self.isFav{
                    if favStatus == "1"{
                        showBanner(title: "", subTitle:"Product is successfully added to favourite" , bannerStyle: .success)
                    }
                     self.arrayHistoryFood[rowId].isFavourite = favStatus
                     self.tableHistory.reloadData()
                }else {
                    self.arrayFavFood.remove(at: rowId)
                    self.tableFav.reloadData()
                    showBanner(title: "", subTitle:"Product is successfully removed from favourite" , bannerStyle: .success)
                    if(self.arrayFavFood.count == 0){
                        self.ShowNoDataMessage()
                    }else {
                        self.HideNoDataMessage()
                    }
                }
            }else {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
    }
  
    
}

class TableViewRowAction: UITableViewRowAction
{
    var image: UIImage?
    
    func _setButton(button: UIButton)
    {
        if let image = image, let titleLabel = button.titleLabel
        {
            let labelString = NSString(string: titleLabel.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: titleLabel.font])
            
//            button.tintColor = UIColor.white
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageEdgeInsets.right = -titleSize.width
        }
    }
}


//MARK:- Table - Delegate - DataSource
extension HistoryVC: UITableViewDelegate,UITableViewDataSource {
    
    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFav{
            return arrayFavFood.count;
        }else {
            return arrayHistoryFood.count;
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 130;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "food_cell", for: indexPath) as! tableFoodCell
         let objProduct: WSProduct
        var createdDate : String = ""
        if isFav{
            objProduct = arrayFavFood[indexPath.row]
            createdDate = "\(objProduct.favouriteCreatedDate ?? "")"
        }else {
            objProduct = arrayHistoryFood[indexPath.row]
            createdDate = "\(objProduct.historyCreatedDate ?? "")"
        }      
 
        if createdDate != "" && createdDate.count > 0{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.labelDate.text =  dateFormatter.string(from: stringToDate(createdDate))
        }
        let imageURL = URL(string: objProduct.productImage ?? "")
        if imageURL != nil
        {
            cell.imgFavouriteFood!.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "food_place_holder"))
        }
        else
        {
            cell.imgFavouriteFood.image = UIImage(named: "food_place_holder")
        }
        cell.productName.text = objProduct.productName ?? ""
        let isHealthy : String = objProduct.isHealthy ?? ""
        if isHealthy != "" && isHealthy.count > 0{
            if isHealthy == "0" {
                 cell.productType.setTitle("\(Poor)", for: .normal)
                 cell.productType.setTitleColor(UIColor(red:  230/255, green: 0/255, blue: 20/255, alpha: 1.0), for: .normal)
                cell.productType.setImage(UIImage(named: "dot_red_small"), for: .normal)
            }else {
                cell.productType.setTitle("Excellent", for: .normal)
                cell.productType.setTitleColor(UIColor(red:  85/255, green: 165/255, blue: 70/255, alpha: 1.0), for: .normal)
                 cell.productType.setImage(UIImage(named: "dot_green_small"), for: .normal)
            }
        }
        cell.btnFav.tag = indexPath.row
        cell.btnFav.addTarget(self, action: #selector(btnFavourite(_:)), for:.touchUpInside)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
        let storyBoard = UIStoryboard(name: StoryBoardMain, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: idFoodDetailVC) as! FoodDetailVC
        if isFav{
            vc.objProduct = arrayFavFood[indexPath.row]
        }else {
            vc.objProduct = arrayHistoryFood[indexPath.row]
        }
        APP_DELEGATE.mainNavigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
//        let whitespace = whitespaceString(width:CGFloat(kCellActionWidth) )
        if isFav{
             let objProduct: WSProduct =  arrayFavFood[indexPath.row]
            let fav = TableViewRowAction(style: UITableViewRowAction.Style.default, title: "Fav") { action, indexPath in
                self.addRemoveFav(productId: objProduct.productId!, rowId: indexPath.row, favStatus: "0")
            }
            fav.backgroundColor = UIColor.lightGray
            fav.image = UIImage(named: "unfav_icon")
            return [fav]
        }else {
            let objProduct: WSProduct =  arrayHistoryFood[indexPath.row]
            let delete = TableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete") {action, indexPath in
                self.removeHistory(historyId: objProduct.historyId!,rowId: indexPath.row)
            }
            delete.image = UIImage(named: "delete_icon")

            var favStatus : String
            if objProduct.isFavourite == "0"{
                favStatus = "UnFav Food,Do Fav"
            }else {
                favStatus = "Fav Food,Make Unfav"
            }
            let fav = TableViewRowAction(style: UITableViewRowAction.Style.default, title: favStatus) { action, indexPath in
                if objProduct.isFavourite == "0" {
                    self.addRemoveFav(productId: objProduct.productId!, rowId: indexPath.row, favStatus: "1")
                }else{
                    self.addRemoveFav(productId: objProduct.productId!, rowId: indexPath.row, favStatus: "0")
                }
//                 showBanner(title: "", subTitle:"Product is successfully added to favourite" , bannerStyle: .success)
            }
            fav.backgroundColor = UIColor.lightGray
            fav.image = UIImage(named: "unfav_icon")
            return [delete,fav]
        }
    
    }

    
    func scrollViewDidEndDecelerating(_ scrollView : UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0{
            if !isLoadMore{
                indicatorView.isHidden = false
                activityIndicator.startAnimating()
                loadMoreRequest()
                isLoadMore = true
            }
        }
        
    }
}

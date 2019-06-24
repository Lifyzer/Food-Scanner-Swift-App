//
//  ProfileVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
//import Crashlytics


class ProfileVC: UIViewController {
    
      enum ProfileItems: Int {
        case UserEmail=0 , FavouriteFood
        case totalCount = 2
      }
      @IBOutlet var buttonLogin: UIButton!
      @IBOutlet var tableProfile: UITableView!
      @IBOutlet var vwNoData: UIView!
      @IBOutlet weak var indicatorView: UIView!
      @IBOutlet weak var lblTitle: UILabel!
      @IBOutlet weak var userName: UILabel!
      @IBOutlet weak var userEmail: UILabel!
      @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
      var isLoadMore:Bool = false
      var arrayFavFood = [WSProduct]()
      var objUser: WSUser?
      var offSet : Int = 0
      var noOfRecords  = REQ_NO_OF_RECORD
      private let refresher = UIRefreshControl()
    var RemoveIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableProfile.tableFooterView = UIView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
           // Crashlytics.sharedInstance().crash()
        
        if checkLoginAlert(){
            objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
            userEmail.text = objUser?.email
            userName.text = objUser?.firstName?.capitalized
            refresher.addTarget(self, action: #selector(initialRequest(_:)), for: .valueChanged)
            tableProfile.refreshControl = refresher
            getFavFood(isLoader: true)
        }
        else
        {
            userEmail.text = "User Email"
            userName.text = "User Name"
            self.vwNoData.isHidden = false
            self.tableProfile.isHidden = true
        }
    }
   
    @IBAction func buttonSettingsClicked(_ sender: Any) {
        
        if checkLoginAlert(){
            self.pushViewController(Storyboard: StoryBoardSettings, ViewController: idSettingsVC, animation: true)
        }
    }
    
    //MARK: Functions
    func checkLoginAlert() -> Bool{
        if !UserDefaults.standard.bool(forKey: kLogIn){
            let alert = UIAlertController(title: APPNAME, message: please_login,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "LOGIN",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            self.pushViewController(Storyboard: StoryBoardLogin, ViewController: idWelComeVC, animation: true)
            }))
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            return true
        }
        return false
    }
    
    @objc func btnFavourite(_ sender: UIButton) {
        let objProduct  = arrayFavFood[sender.tag]
        RemoveIndex = sender.tag
        AddRemoveFromFavouriteAPI(isFavourite : "0", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
    }
    func AfterAPICall(){
        arrayFavFood.remove(at:RemoveIndex)
        tableProfile.reloadData()
    }
    
    @objc private func initialRequest(_ sender: Any) {
        self.offSet = 0
        getFavFood(isLoader: false)
    }

    func loadMoreRequest() {
        self.offSet = arrayFavFood.count
        getFavFood(isLoader: false)
    }
    
    func getFavFood(isLoader : Bool){
        
        if Connectivity.isConnectedToInternet
        {
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
            let param:NSMutableDictionary = [
                WS_KTo_index:noOfRecords,
                WS_KFrom_index:offSet,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
//                WS_KAccess_key:DEFAULT_ACCESS_KEY,
//                WS_KSecret_key:userToken ?? ""]
                includeSecurityCredentials {(data) in
                    let data1 = data as! [AnyHashable : Any]
                    param.addEntries(from: data1)
                }
        
            if(isLoader){
                showIndicator(view: self.view)
            }
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetAllUserFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                if(isLoader){
                    self.hideIndicator(view: self.view)}
                if response != nil
                {
                    let objData = JSON(response!)[WS_KProduct]
                    self.arrayFavFood = objData.to(type: WSProduct.self) as! [WSProduct]
                    if self.arrayFavFood.count > 0{
                        self.tableProfile.isHidden = false
                        self.vwNoData.isHidden = true
                        self.tableProfile.reloadData()
                    }else {
                        self.vwNoData.isHidden = false
                        self.tableProfile.isHidden = true                        
                    }
                    
                    if self.isLoadMore{
                        self.isLoadMore = false
                        self.indicatorView.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                }else {
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
//                    self.generateAlertWithOkButton(text:message!)

//                    showBanner(title: "", subTitle: message!, bannerStyle: .danger)
                }
                })
            }
            else
            {
                self.generateAlertWithOkButton(text:no_internet_connection)

//                showBanner(title: "", subTitle: no_internet_connection, bannerStyle: .danger)
            }
        }

}

//MARK:- Table - Delegate - DataSource
extension ProfileVC: UITableViewDelegate,UITableViewDataSource {

    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return arrayFavFood.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 130//UITableView.automaticDimension//120;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fav_food_cell", for: indexPath) as! tableFoodCell
        let objProduct: WSProduct = arrayFavFood[indexPath.row]
        let createdDate : String = "\(objProduct.favouriteCreatedDate ?? "")"
        if createdDate != "" && createdDate.count > 0{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.labelDate.text =  dateFormatter.string(from: stringToDate(createdDate))
        }
        cell.productName.text = objProduct.productName ?? ""
        cell.btnFav.tag = indexPath.row
        cell.btnFav.addTarget(self, action: #selector(btnFavourite(_:)), for:.touchUpInside)
        let imageURL = URL(string: objProduct.productImage ?? "")
        cell.imgFavouriteFood.contentMode = .scaleAspectFill
        if imageURL != nil
        {
            cell.imgFavouriteFood!.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "food_place_holder"))
        }
        else
        {
            cell.imgFavouriteFood.image = UIImage(named: "food_place_holder")
        }
       
        let isHealthy : String = objProduct.isHealthy ?? ""
        if isHealthy != "" && isHealthy.count > 0{
            if isHealthy == "0" {
                cell.productType.setTitle("\(Poor)", for: .normal)
                cell.productType.setTitleColor(UIColor(red:  230/255, green: 0/255, blue: 20/255, alpha: 1.0), for: .normal)
                cell.productType.setImage(UIImage(named: "dot_red_small"), for: .normal)
            }else {
                cell.productType.setTitle("\(Excellent)", for: .normal)
                cell.productType.setTitleColor(UIColor(red:  85/255, green: 165/255, blue: 70/255, alpha: 1.0), for: .normal)
                cell.productType.setImage(UIImage(named: "dot_green_small"), for: .normal)
            }
        }
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = loadViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC) as! FoodDetailVC
        vc.objProduct = arrayFavFood[indexPath.row]
        vc.objProduct.isFavourite = 1
      
        self.navigationController?.pushViewController(vc, animated: true)
//        pushViewController(Storyboard: StoryBoardMain, ViewController: idFoodDetailVC, animation: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView : UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
//        if maximumOffset - currentOffset <= 10.0{
//            if !isLoadMore{
//                indicatorView.isHidden = false
//                activityIndicator.startAnimating()
//                loadMoreRequest()
//                isLoadMore = true
//            }
//        }
        
    }
}



//
//  HistoryVC.swift
//  FoodScan
//
//  Created by C110 on 07/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON
import UILoadControl


let History_Action_color = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
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
    let refresher:UIRefreshControl! = UIRefreshControl()
    var refresh:UIRefreshControl! = UIRefreshControl()
    var offSet : Int = 0
    var noOfRecords  = REQ_NO_OF_RECORD
    var RemoveIndex = -1
    var EditIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshData()

        tableHistory.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        tableHistory.loadControl?.heightLimit = 0.0//100.0
        tableHistory.loadControl?.isHidden = true
        tableFav.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        tableFav.loadControl?.heightLimit = 0.0//100.0
        tableFav.loadControl?.isHidden = true
        self.tableHistory.tableFooterView = UIView()
        self.tableFav.tableFooterView = UIView()
        isFav = false
        self.setView(view: tableHistory , hidden: false)
        self.setView(view: tableFav, hidden: true)
        vwHistory.isHidden = false
        vwFav.isHidden = true
        tableFav.isHidden = true
        tableHistory.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        checkLoginAlert()
    }

    //MARK:- Refresh Table
    func setupRefreshData() {
        self.refresh.backgroundColor = UIColor.white
        self.refresh.tintColor = UIColor.black
        self.refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableHistory!.addSubview(refresh)
        self.refresher.backgroundColor = UIColor.white
        self.refresher.tintColor = UIColor.black
        self.refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableFav!.addSubview(refresher)
    }

    @objc func refreshData() {
        self.refresh.beginRefreshing()
        offSet = 0
        if isFav{
            getFavFood(isLoader: false)
        }else{
            getHistory(isLoader: false)
        }
    }

    func stopRefresh() {
        if isFav{
            self.refresher.endRefreshing()
        }else{
            self.refresh.endRefreshing()
        }
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

    func AfterAddRemoveFavAPI()
    {
        if isFav{
            let objProduct = arrayFavFood[RemoveIndex]
            arrayFavFood.remove(at:RemoveIndex)
            tableFav.reloadData()
            if(self.arrayFavFood.count == 0){
                self.ShowNoDataMessage()
            }else {
                self.HideNoDataMessage()
            }
        }else{
            let objProduct = arrayHistoryFood[EditIndex]
            if objProduct.isFavourite.aIntOrEmpty() == 1 {
                objProduct.isFavourite = 0
            }else{
                objProduct.isFavourite = 1
            }
            tableHistory.reloadData()
        }
    }
    func SetImageInEditAction(indexPath : IndexPath,tableview:UITableView,imageName:String) -> UIImage
    {
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: tableview.frame.size.height))
        backView.backgroundColor = History_Action_color//UIColor(red: 239/255.0, green: 34/255.0, blue: 91/255.0, alpha: 1.0)
        let frame = tableview.rectForRow(at: indexPath)
        let myImage = UIImageView(frame: CGRect(x: 20, y: frame.size.height/2-20, width: 30, height: 30))
        myImage.image = UIImage(named: imageName)!
        backView.addSubview(myImage)
        let imgSize: CGSize = frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    @objc func btnFavourite(_ sender: UIButton) {
        let objProduct  = arrayFavFood[sender.tag]
        RemoveIndex = sender.tag
        if objProduct.isFavourite.aIntOrEmpty() == 0 {
            AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
        }else if objProduct.isFavourite.aIntOrEmpty() == 1{
            AddRemoveFromFavouriteAPI(isFavourite : "0", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
        }else{
            AddRemoveFromFavouriteAPI(isFavourite : "1", product_id:objProduct.id.asStringOrEmpty(),fn:AfterAPICall)
        }
    }
    func AfterAPICall(){
        arrayFavFood.remove(at:RemoveIndex)
        if(self.arrayFavFood.count == 0){
            self.ShowNoDataMessage()
        }else {
            self.HideNoDataMessage()
        }
    }
    func btnFavClicked()
    {
        offSet = 0
        if arrayFavFood.count == 0{
            self.getFavFood(isLoader: true)
        }else{
            self.getFavFood(isLoader: false)
        }
        vwNoData.isHidden = true
        self.tableHistory.isHidden = true
        self.tableFav.isHidden = false
    }
    func btnHistotyClicked() {
        offSet = 0
        if arrayHistoryFood.count == 0{
            self.getHistory(isLoader: true)
        }else{
            self.getHistory(isLoader: false)
        }
        vwNoData.isHidden = true
        self.tableHistory.isHidden = false
        self.tableFav.isHidden = true
    }
    func checkLoginAlert(){
        ShowNoDataMessage()
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
            objUser = UserDefaults.standard.getCustomObjFromUserDefaults(forKey: KUser) as? WSUser
            stopRefresh()
            tableFav.reloadData()
            tableHistory.reloadData()
            if isFav{
                btnFavClicked()
            }else {
                btnHistotyClicked()
            }
        }
    }

    //MARK:- Button click
    @IBAction func buttonHistoryClicked(_ sender: Any) {
        isFav = false
        vwHistory.isHidden = false
        vwFav.isHidden = true
        tableFav.isHidden = true
        tableHistory.isHidden = false
        checkLoginAlert()
    }

    @IBAction func buttonFavClicked(_ sender: Any) {
        isFav = true
        vwHistory.isHidden = true
        vwFav.isHidden = false
        tableFav.isHidden = false
        tableHistory.isHidden = true
        checkLoginAlert()
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
            self.offSet = arrayFavFood.count //offSet +
            getFavFood(isLoader: false)
        }else {
            self.offSet = arrayHistoryFood.count //offSet +
            getHistory(isLoader: false)
        }
    }

    func getFavFood(isLoader : Bool)
    {
        if Connectivity.isConnectedToInternet
        {
            if isLoader{
                showIndicator(view: self.view)
            }
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(UserDefaults.standard.string(forKey: kUserGUID), keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
            print("encode string : \(encodeString!)")

            let param:NSMutableDictionary = [
                WS_KTo_index:noOfRecords,
                WS_KFrom_index:offSet,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
            print(param)
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetAllUserFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                if(isLoader){
                    self.hideIndicator(view: self.view)}
                if response != nil
                {
                    let objData = JSON(response!)[WS_KProduct]
                    let tempArray  = objData.to(type: WSProduct.self) as! [WSProduct]
                    if tempArray.count > 0{
                        if self.offSet == 0{
                            self.arrayFavFood.removeAll()
                            self.arrayFavFood = tempArray
                        }else{
                            self.arrayFavFood.append(contentsOf: tempArray)
                        }
                        self.tableFav.loadControl?.endLoading()
                        self.tableFav.reloadData()
                    }
                    else
                    {
                        if self.offSet == 0{
                            self.arrayFavFood.removeAll()
                            self.tableFav.reloadData()
                        }
                    }
                    if(self.arrayFavFood.count == 0){
                        self.ShowNoDataMessage()
                    }else {
                        self.HideNoDataMessage()
                        if isLoader {
                        }
                    }

                    if self.isLoadMore{
                        self.isLoadMore = false
                    }
                }else {
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
                }
                self.stopRefresh()
            })
        }
        else
        {
            self.stopRefresh()
            SHOW_ALERT_VIEW(TITLE: "", DESC: no_internet_connection, STATUS: .error, TARGET: self)
        }

    }

    func getHistory(isLoader : Bool){
        if Connectivity.isConnectedToInternet
        {
            if isLoader{
                showIndicator(view: self.view)}
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(UserDefaults.standard.string(forKey: kUserGUID).asStringOrEmpty(), keyString: UserDefaults.standard.string(forKey: kGlobalPassword).asStringOrEmpty(), keyIv: UserDefaults.standard.string(forKey: KKey_iv).asStringOrEmpty(), separateLines: false)
            print("encode string : \(encodeString!)")
            let param:NSMutableDictionary = [
                WS_KTo_index:noOfRecords,
                WS_KFrom_index:offSet,
                WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            print("===== Hisroty Param =======",param)

            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIGetUserHistory, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                if(isLoader){
                    self.hideIndicator(view: self.view)}
                if response != nil
                {
                    let objData = JSON(response!)[WS_KHistory]
                    let tempArray  = objData.to(type: WSProduct.self) as! [WSProduct]
                    if tempArray.count > 0{
                        if self.offSet == 0 {
                            self.arrayHistoryFood.removeAll()
                            self.arrayHistoryFood = tempArray
                        }else{
                            self.arrayHistoryFood.append(contentsOf: tempArray)
                        }
                        self.tableHistory.loadControl?.endLoading()
                        self.tableHistory.reloadData()
                    }
                    else
                    {
                        //                        self.arrayHistoryFood.append(contentsOf: tempArray)
                        //                         self.tableHistory.loadControl?.endLoading()
                        //                        self.tableHistory.reloadData()
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
                    }

                }else {
                    if(self.arrayHistoryFood.count == 0){
                        self.ShowNoDataMessage()
                    }else {
                        self.HideNoDataMessage()
                        if isLoader {
                            self.tableHistory.reloadData()
                        }
                    }
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
                }
                self.stopRefresh()
            })
        }
        else
        {
            self.stopRefresh()
            SHOW_ALERT_VIEW(TITLE: "", DESC: no_internet_connection, STATUS: .error, TARGET: self)
        }
    }

    func removeHistory(historyId : String, rowId :Int){
        if Connectivity.isConnectedToInternet
        {
            let userToken = UserDefaults.standard.string(forKey: kTempToken)
            let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
            let param:NSMutableDictionary = [
                WS_KHistory_id:historyId]
            includeSecurityCredentials {(data) in
                let data1 = data as! [AnyHashable : Any]
                param.addEntries(from: data1)
            }
            HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIRemoveProductFromHistory, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                if response != nil
                {
                    if(self.arrayHistoryFood.count == 0){
                        self.ShowNoDataMessage()
                    }else {
                        self.HideNoDataMessage()
                    }
                    self.tableHistory.reloadData()
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
                }else {
                    SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)

                }
            })
        }
        else
        {
            SHOW_ALERT_VIEW(TITLE: "", DESC: no_internet_connection, STATUS: .error, TARGET: self)
        }
    }

    //    func addRemoveFav(productId : String, rowId :Int, favStatus : Int){
    //        let userToken = UserDefaults.standard.string(forKey: kTempToken)
    //        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
    //        let param:NSMutableDictionary = [
    //            WS_KUser_id:objUser?.userId,
    //            WS_KProduct_id:productId,
    //            WS_KIs_favourite:favStatus,
    //            WS_KAccess_key:DEFAULT_ACCESS_KEY,
    //            WS_KSecret_key:userToken ?? ""]
    //        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddToFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
    //            if response != nil
    //            {
    //                if !self.isFav{
    //                    if favStatus == 1{
    //                        showBanner(title: "", subTitle:"Product is successfully added to favourite" , bannerStyle: .success)
    //                    }
    //                    else
    //                    {
    //                        showBanner(title: "", subTitle:"Product is successfully removed from favourite" , bannerStyle: .success)
    //                    }
    //                     self.arrayHistoryFood[rowId].isFavourite = favStatus
    //                     self.tableHistory.reloadData()
    //                }else {
    //                    self.arrayFavFood.remove(at: rowId)
    //                    self.tableFav.reloadData()
    //                    showBanner(title: "", subTitle:"Product is successfully removed from favourite" , bannerStyle: .success)
    //
    //                    if(self.arrayFavFood.count == 0){
    //                        self.ShowNoDataMessage()
    //                    }else {
    //                        self.HideNoDataMessage()
    //                    }
    //                }
    //            }else {
    //                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
    //            }
    //        })
    //    }


}

//class TableViewRowAction: UITableViewRowAction
//{
//    var image: UIImage?
//
//    func _setButton(button: UIButton)
//    {
//        if let image = image, let titleLabel = button.titleLabel
//        {
//            let labelString = NSString(string: titleLabel.text!)
//            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: titleLabel.font])
//
////            button.tintColor = UIColor.white
//            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
//            button.imageEdgeInsets.right = -titleSize.width
//        }
//    }
//}


//MARK:- Table - Delegate - DataSource
extension HistoryVC: UITableViewDelegate,UITableViewDataSource {

    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFav
        {
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
        var objProduct: WSProduct
        var createdDate : String = ""

        if isFav{
            objProduct = arrayFavFood[indexPath.row]
            createdDate = "\(objProduct.favouriteCreatedDate ?? "")"
        }else {
            objProduct = arrayHistoryFood[indexPath.row]
            //            if objProduct.id.asStringOrEmpty() == arrayHistoryFood.last?.id.asStringOrEmpty()
            //            {
            //
            //                indicatorView.isHidden = false
            //                activityIndicator.startAnimating()
            //                loadMoreRequest()
            //                isLoadMore = true
            //            }
            createdDate = "\(objProduct.historyCreatedDate ?? "")"
        }

        if createdDate != "" && createdDate.count > 0{
            //Chnaged on 13/5/2019
            let StrAfterConvert = ConvertDate(format: "yyyy-MM-dd HH:mm:ss", str: createdDate)
            //            print(dt)
            //            let df = DateFormatter()
            //            df.dateFormat = "dd/MM/yyyy"
            //            let str = df.string(from: dt!)
            //            print(dt,str)
            //

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.labelDate.text = dateFormatter.string(from: stringToDate(createdDate))//StrAfterConvert


        }
        let imageURL = URL(string: objProduct.productImage.asStringOrEmpty())
        if imageURL != nil
        {
            cell.imgFavouriteFood!.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "food_place_holder"))
        }
        else
        {
            cell.imgFavouriteFood.image = UIImage(named: "food_place_holder")
        }
        cell.productName.text = objProduct.productName.asStringOrEmpty()
        let isHealthy : String = objProduct.isHealthy.asStringOrEmpty()
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
        //        cell.btnFav.addTarget(self, action: #selector(btnFavourite(_:)), for:.touchUpInside)
        cell.selectionStyle = .none
        return cell

    }
    func ConvertDate(format: String,str:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: str)

        //        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let strAfterConvert = dateFormatter.string(from: dt!)

        return strAfterConvert//dateFormatter.string(from: dt!)
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

    //    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //
    //        if isFav{
    //            let objProduct: WSProduct =  arrayFavFood[indexPath.row]
    //            let fav =  UIContextualAction(style: .normal, title: "", handler: { (action,view,completionHandler ) in
    //                self.RemoveIndex = indexPath.row
    //                self.AddRemoveFromFavouriteAPI(isFavourite: "0", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)
    //
    //            })
    //            let imgFav = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: "fav_icon")
    //            fav.backgroundColor = UIColor(patternImage: imgFav)
    //            let configuration = UISwipeActionsConfiguration(actions: [fav])
    //             configuration.performsFirstActionWithFullSwipe = false
    //            return configuration
    //        }
    //        else {
    //            let objProduct: WSProduct =  arrayHistoryFood[indexPath.row]
    //            let delete =  UIContextualAction(style: .destructive, title: "", handler: { (action,view,completionHandler ) in
    //                self.removeHistory(historyId: objProduct.historyId!,rowId: indexPath.row)
    //            })
    //            let img = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: "delete_icon")
    //            delete.backgroundColor = UIColor(patternImage: img)
    //            var favStatus : String
    //            if objProduct.isFavourite == "1"{
    //                favStatus = "fav_icon"
    //            }else {
    //                favStatus = "unfav_icon"
    //            }
    //            let fav =  UIContextualAction(style: . normal, title: "", handler: { (action,view,completionHandler ) in
    //                self.EditIndex = indexPath.row
    //                if objProduct.isFavourite == "1" {
    //                    self.AddRemoveFromFavouriteAPI(isFavourite: "0", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)
    //
    //                }else{
    //                    self.AddRemoveFromFavouriteAPI(isFavourite: "1", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)
    //
    //                }
    //
    //            })
    //            let imgFav = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: favStatus)
    //            fav.backgroundColor = UIColor(patternImage: imgFav)
    //
    //            let configuration = UISwipeActionsConfiguration(actions: [fav,delete])
    //            configuration.performsFirstActionWithFullSwipe = false
    //            return configuration
    //        }
    //    }


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        //        let whitespace = whitespaceString(width:CGFloat(kCellActionWidth) )
        if isFav{
            let objProduct: WSProduct =  arrayFavFood[indexPath.row]
            let fav = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "") { action, indexPath in

                self.RemoveIndex = indexPath.row
                self.AddRemoveFromFavouriteAPI(isFavourite: "0", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)
            }
            let imgFav = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: "fav_icon")
            fav.backgroundColor = UIColor(patternImage: imgFav)
            return [fav]
        }else {
            let objProduct: WSProduct =  arrayHistoryFood[indexPath.row]
            let delete = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "") {action, indexPath in
                self.removeHistory(historyId: objProduct.historyId!,rowId: indexPath.row)
            }
            let img = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: "delete_icon")
            delete.backgroundColor = UIColor(patternImage: img)
            var favStatus : String
            if objProduct.isFavourite.asStringOrEmpty() == "1"{
                favStatus = "fav_icon"
            }else {
                favStatus = "unfav_icon"
            }
            let fav = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "") { action, indexPath in
                self.EditIndex = indexPath.row
                if objProduct.isFavourite.aIntOrEmpty() == 1 {
                    self.AddRemoveFromFavouriteAPI(isFavourite: "0", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)

                }else{
                    self.AddRemoveFromFavouriteAPI(isFavourite: "1", product_id: objProduct.id.asStringOrEmpty(), fn: self.AfterAddRemoveFavAPI)
                }
            }
            let imgFav = SetImageInEditAction(indexPath: indexPath, tableview: tableView, imageName: favStatus)
            fav.backgroundColor = UIColor(patternImage: imgFav)
            return [delete,fav]
        }
    }
}
extension HistoryVC : UIScrollViewDelegate
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

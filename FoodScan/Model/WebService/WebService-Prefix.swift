//
//  WebService-Prefix.swift
//  SwiftDemo
//
//  Created by C79 on 18/04/16.
//  Copyright © 2016 Narolainfotech. All rights reserved.
//

import Foundation

//Service Type
let GET = "GET"
let POST = "POST"
let MEDIA = "MEDIA"

let MESSAGE = "Please try again later."

//Web Service Path
let WEBSERVICE_PATH = "/api/WS/FoodScanAppService.php?Service="

//Images Path

//let PATHCATEGORY = "\(SERVER_URL)pg/Bazinga/uploads/sub_categories/"
//let PATHPRODUCTMEDIA = "\(SERVER_URL)pg/Bazinga/uploads/products/media/images/"

//Service Name
let APIRefreshToken = "\(SERVER_URL)\(WEBSERVICE_PATH)refreshToken"
let APIUpdateToken = "\(SERVER_URL)\(WEBSERVICE_PATH)updateTokenForUser"
let APILogin = "\(SERVER_URL)\(WEBSERVICE_PATH)Login"
let APIRegistration = "\(SERVER_URL)\(WEBSERVICE_PATH)Registration"
let APIGetProductDetails = "\(SERVER_URL)\(WEBSERVICE_PATH)getProductDetails"
let APIAddToFavourite = "\(SERVER_URL)\(WEBSERVICE_PATH)addToFavourite"
let APIGetAllUserFavourite = "\(SERVER_URL)\(WEBSERVICE_PATH)getAllUserFavourite"
let APIRemoveProductFromHistory = "\(SERVER_URL)\(WEBSERVICE_PATH)removeProductFromHistory"
let APIGetUserHistory = "\(SERVER_URL)\(WEBSERVICE_PATH)getUserHistory"
let APIChangePassword = "\(SERVER_URL)\(WEBSERVICE_PATH)ChangePassword"
let APIEditProfile = "\(SERVER_URL)\(WEBSERVICE_PATH)EditProfile"
let APItestEncryption = "\(SERVER_URL)\(WEBSERVICE_PATH)testEncryption"
let APIForgotPassword = "\(SERVER_URL)\(WEBSERVICE_PATH)ForgotPassword"
let APIAddReview = "\(SERVER_URL)\(WEBSERVICE_PATH)addReview"

//Model
let WSUSER = "User"
let WSFEEDS = "Feeds"
let WSFeedComment = "FeedComment"

//RequestKey Parameter
let WS_KAccess_key = "access_key"
let WS_KEmail_id = "email_id"
let WS_KPassword = "password"
let WS_KFirst_name = "first_name"
let WS_KLast_name = "last_name"
let WS_KDevice_type = "device_type"
let WS_KSecret_key = "secret_key"
let WS_KUser_id = "user_id"
let WS_KProduct_name = "product_name"
let WS_KIs_favourite = "is_favourite"
let WS_KProduct_id = "product_id"
let WS_KTo_index = "to_index"
let WS_KHistory_id = "history_id"
let WS_KFrom_index = "from_index"
let WS_KNew_password = "new_password"
let WS_KGuid = "guid"
let WS_KProduct = "product"
let WS_KHistory = "history"
let WS_FLAG = "flag"
let WS_RATTING = "ratting"
let WS_TITLE = "title"
let WS_DESC = "desc"
let WS_IS_TEST = "is_testdata"

let IS_TESTDATA = "1"

var arrayFavouriteProducts:[WSProduct] = [WSProduct]()

//MARK:- Connectivity
import Alamofire
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

 //
//  WeServicesCollector.swift
//  Heaconn
//
//  Created by C217 on 04/05/16.
//  Copyright © 2016 C81. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class WebServicesCollection
{
    static let sharedInstance = WebServicesCollection()

    // METHODS
    init() {}

    //MARK:- Login/Register Method
    func loginUser(userName:String, password: String, responseData:@escaping (_ userObj:WSUser?,_ error:Error?,_ message:String?) -> Void) {
        let ParametersDict: NSDictionary = [
            "username" : userName,
            "password": password]

        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl:APILogin, parameters: ParametersDict) { (response, error, message) in
            if response != nil {
                if(error == nil) {
                    _ = JSON(response!)[WSKUser].array
//                    let userObj = objData![0].to(type: WSUser.self) as? WSUser
                    responseData(nil, error, message)
                }
            } else {
                responseData(nil, error, message)
            }
        }
    }

    func RegisterUser(ParametersDict:NSDictionary, responseData:@escaping (_ userObj:WSUser?,_ error:Error?,_ message:String?) -> Void) {

        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl:APIRegistration, parameters: ParametersDict) { (response, error, message) in
            if response != nil {
                if(error == nil) {
                    _ = JSON(response!)[WSKUser].array
//                    let userObj = objData![0].to(type: WSUser.self) as? WSUser
                    responseData(nil, error, message)
                }
            } else {
                responseData(nil, error, message)
            }
        }
    }

    func forgotPassword(userName:String, responseData:@escaping (_ error:Error?,_ message:String?) -> Void) {
        let ParametersDict: NSDictionary = [
            "username" : userName]
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl:APIForgotPassword, parameters: ParametersDict) { (response, error, message) in
            if(error == nil) {
                responseData(nil, message)
            } else {
                responseData(error, message)
            }
        }
    }
//
//    func getUserDetails(responseData:@escaping (_ userObj:UserModel?,_ error:Error?,_ message:String?) -> Void) {
//
//        let ParametersDict: NSDictionary = [
//            "user_id" : "\(APP_DELEGATE.APPUSER.userId!)"]
//
//        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl:APIGetUserDetails, parameters: ParametersDict) { (response, error, message) in
//            if response != nil {
//                let objData = JSON(response!)[WSDATA].array
//                if(objData != nil) {
//                    let userObj = objData![0].to(type: UserModel.self) as? UserModel
//                    responseData(userObj, error, message)
//                } else {
//                    responseData(nil, error, message)
//                }
//            } else {
//                responseData(nil, error, message)
//            }
//        }
//    }
//
//
//
//    func checkIfDeviceTokenExists(responseData:@escaping (_ error:Error?,_ message:String?) -> Void)
//    {
//        let ParametersDict: NSDictionary =  [
//            "device_token" : UserDefaults.standard.getDeviceToken(),
//            "user_id" : "\(APP_DELEGATE.APPUSER.userId!)"
//        ]
//
//        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl:APIUpdateDeviceToken, parameters: ParametersDict) { (response, error, message) in
//            responseData(error, message)
//        }
//    }
//
//    func registerUser(userId:Int,name:String,nickName:String, profilePhoto:UIImage?,city:String,email:String, responseData:@escaping (_ userObj:UserModel?,_ error:Error?,_ message:String?) -> Void) {
//
//        let ParametersDict: NSMutableDictionary = [
//            "user_id" : "\(userId)",
//            "first_name": name,
//            "last_name": "",
//            "device_token":UserDefaults.standard.getDeviceToken(),
//            "nick_name": nickName,
//            "email": email,
//            "city":city]
//
//        if(profilePhoto != nil) {
//            ParametersDict.setValue(profilePhoto, forKey: "media_file")
//        }
//
//        print("Param : \(ParametersDict)")
//
//        HttpRequestManager.sharedInstance.postMultipartJSONRequest(endpointurl: APIRegister, parameters: ParametersDict) { (response, error, message) in
//            if response != nil {
//                let objData = JSON(response!)[WSDATA].array
//                if(objData != nil) {
//                    let userObj = objData![0].to(type: UserModel.self) as? UserModel
//                    responseData(userObj, error, message)
//                } else {
//                    responseData(nil, error, message)
//                }
//            } else {
//                responseData(nil, error, message)
//            }
//        }
//    }


}



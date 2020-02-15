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
}



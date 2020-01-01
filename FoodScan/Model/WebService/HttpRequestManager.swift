//
//  HttpRequestManager.swift
//  SwiftDemo
//
//  Created by C79 on 16/04/16.
//  Copyright © 2016 Narolainfotech. All rights reserved.
//

import UIKit
import Alamofire

//Encoding Type
let URL_ENCODING = URLEncoding.default
let JSON_ENCODING = JSONEncoding.default

//Web Service Result
let WSSUCCESS = "success"
let WSMESSAGE = "message"
let WSDATA = "data"
let WSRESPONSE = "Response"
let WSERRORMSG = "errorMsg"
let WSSTATUS = "status"
let WSKCategories = "categories"
let WSKSections = "sections"
let WSKChannels = "channels"
let WSKUser = "User"
let WSKUserToken = "UserToken"

public enum RESPONSE_STATUS : String
{
    case SUCCESS = "success"
    case FAILED = "failed"
}



protocol UploadProgressDelegate
{
    func didReceivedProgress(progress:Float)
}
protocol DownloadProgressDelegate
{
    func didReceivedDownloadProgress(progress:Float,filename:String)
    func didFailedDownload(filename:String)
}

class HttpRequestManager
{
    static let sharedInstance = HttpRequestManager()
    let additionalHeader = ["User-Agent": "iOS",
                            "Content-Type":"application/json"]
    var responseObjectDic = Dictionary<String, AnyObject>()
    var URLString : String!
    var Message : String!
    var resObjects:AnyObject!
    var alamoFireManager = Alamofire.SessionManager.default
    var delegate : UploadProgressDelegate?
    var downloadDelegate : DownloadProgressDelegate?


    // METHODS
    init()
    {
        alamoFireManager.session.configuration.timeoutIntervalForRequest = 15 //seconds
        alamoFireManager.session.configuration.httpAdditionalHeaders = additionalHeader
    }

    //MARK:- POST Request
    func postJSONRequest(endpointurl:String, parameters:NSDictionary, encodingType:ParameterEncoding = JSONEncoding.default, responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)

        alamoFireManager.request(endpointurl, method: .post, parameters: parameters as? Parameters, encoding: encodingType, headers: additionalHeader)
            
            .responseString(completionHandler: { (response) in
                print(response)
            })

            .responseJSON { (response:DataResponse<Any>) in

            ShowNetworkIndicator(xx: false)

            if let _ = response.result.error
            {
                let code = (response.result.error as? NSError)!.code
                switch code
                {
                    case -1001 :
                         responseData(nil, response.result.error as NSError?,MESSAGE)
                        break
                    case -1005 :
                        responseData(nil, response.result.error as NSError?,MESSAGE)
                        break
                    default:
                   //  responseData(nil, response.result.error as NSError?,response.result.error?.localizedDescription)//MESSAGE)
                     responseData(nil, response.result.error as NSError?,MESSAGE)

                        break
                }
//                responseData(nil, response.result.error as NSError?,response.result.error?.localizedDescription/*MESSAGE*/)
            }
            else
            {
                switch(response.result)
                {
                case .success(_):
                    if let data = response.result.value
                    {
                        self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
                        let responseStatus = (data as! NSDictionary)[WSSTATUS].asStringOrEmpty()
                        switch (responseStatus) {

                        case RESPONSE_STATUS.SUCCESS.rawValue :
                            self.resObjects = (data as! NSDictionary) as AnyObject
                            break

                        case RESPONSE_STATUS.FAILED.rawValue :
                            self.resObjects = nil
                            break

                        default :
                            break
                        }
                        responseData(self.resObjects, nil, self.Message)
                    }
                    break
                case .failure(_):
                    responseData(nil, response.result.error as NSError?,MESSAGE)
                    break

                }
            }
        }

//            .responseString { (response) in
//                print("Response String",response)
//        }
    }
    func postJSONRequestSecurity(endpointurl:String, parameters:NSDictionary, encodingType:ParameterEncoding = JSONEncoding.default, responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        alamoFireManager.request(endpointurl, method: .post, parameters: parameters as? Parameters, encoding: encodingType, headers: additionalHeader)

            .responseJSON { (response:DataResponse<Any>) in

                ShowNetworkIndicator(xx: false)

                if let _ = response.result.error
                {
                    responseData(nil, response.result.error as NSError?,MESSAGE)
                }
                else
                {
                    switch(response.result)
                    {
                    case .success(_):
                        if let data = response.result.value
                        {
                            self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
//                            let responseStatus = Int((data as! NSDictionary)[WSSTATUS].asStringOrEmpty())
//                            switch (responseStatus) {
//
//                            case RESPONSE_STATUS.VALID.rawValue :
//                                self.resObjects = (data as! NSDictionary) as AnyObject
//                                break
//
//                            case RESPONSE_STATUS.INVALID.rawValue :
//                                self.resObjects = nil
//                                break
//
//                            default :
//                                self.resObjects = (data as! NSDictionary) as AnyObject
//                                break
//                            }
                            responseData((data as! NSDictionary) as AnyObject, nil, self.Message)
                        }
                        break
                    case .failure(_):
                        responseData(nil, response.result.error as NSError?, MESSAGE)
                        break
                    }
                }
        }
    }

    //MARK:- GET Request
    func getRequestWithoutParams(endpointurl:String,responseData:@escaping (_ data:AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)
        alamoFireManager.request(endpointurl, method: .get).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)

            if let _ = response.result.error
            {
                responseData(nil, response.result.error as NSError?,MESSAGE)
            }
            else
            {
                switch(response.result)
                {
                case .success(_):

                    if let data = response.result.value
                    {
                        self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
                        let responseStatus = (data as! NSDictionary)[WSSTATUS].asStringOrEmpty()
                        switch (responseStatus) {

                        case RESPONSE_STATUS.SUCCESS.rawValue :
                            self.resObjects = (data as! NSDictionary) as AnyObject
                            break

                        case RESPONSE_STATUS.FAILED.rawValue :
                            self.resObjects = nil
                            break

                        default :
                            break
                        }
                        responseData(self.resObjects, nil, self.Message)
                    }
                    break

                case .failure(_):
                    responseData(nil, response.result.error as NSError?,MESSAGE)
                    break

                }
            }
        }
    }

    func getRequest(endpointurl:String,parameters:NSDictionary,responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)

        alamoFireManager.request(endpointurl, method: .get, parameters: parameters as? [String : AnyObject]).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)

            if let _ = response.result.error
            {
                responseData(nil, response.result.error as NSError?, MESSAGE)
            }
            else
            {
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value
                    {
                        self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
                        let responseStatus = (data as! NSDictionary)[WSSUCCESS].asStringOrEmpty()
                        switch (responseStatus) {

                        case RESPONSE_STATUS.SUCCESS.rawValue :
                            self.resObjects = (data as! NSDictionary) as AnyObject
                            break

                        case RESPONSE_STATUS.FAILED.rawValue :
                            self.resObjects = nil
                            break

                        default :
                            break
                        }
                        responseData(self.resObjects, nil, self.Message)
                    }
                    break

                case .failure(_):
                    responseData(nil, response.result.error as NSError?, MESSAGE)
                    break

                }
            }
        }

    }


    //MARK:- PUT Request
    func putRequest(endpointurl:String,parameters:NSDictionary,responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
    {
        ShowNetworkIndicator(xx: true)

        alamoFireManager.request(endpointurl, method: .post, parameters: parameters as? Parameters).responseJSON { (response:DataResponse<Any>) in
            ShowNetworkIndicator(xx: false)
            if let _ = response.result.error
            {
                responseData(nil, response.result.error as NSError?, MESSAGE)
            }
            else
            {
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value
                    {
                        self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
                        let responseStatus = (data as! NSDictionary)[WSSUCCESS].asStringOrEmpty()
                        switch (responseStatus) {

                        case RESPONSE_STATUS.SUCCESS.rawValue :
                            self.resObjects = (data as! NSDictionary) as AnyObject
                            break

                        case RESPONSE_STATUS.FAILED.rawValue :
                            self.resObjects = nil
                            break

                        default :
                            break
                        }
                        responseData(self.resObjects, nil, self.Message)
                    }
                    break

                case .failure(_):
                    responseData(nil, response.result.error as NSError?, MESSAGE)
                    break

                }
            }
        }
    }

    //MARK:- Cancel Request
    func cancelAllAlamofireRequests(responseData:@escaping ( _ status: Bool?) -> Void)
    {
       alamoFireManager.session.getTasksWithCompletionHandler
            {
                dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
                responseData(true)
        }
    }

//    func postMultipartJSONRequest(endpointurl:String, parameters:NSDictionary, encodingType:ParameterEncoding = JSONEncoding.default, responseData:@escaping (_ data: AnyObject?, _ error: NSError?, _ message: String?) -> Void)
//    {
//        ShowNetworkIndicator(xx: true)
//
//        alamoFireManager.upload(multipartFormData: { (multipartFormData) in
//
//            for (key, value) in parameters
//            {
//                if value is UIImage {
//                    let imageData:Data = UIImageJPEGRepresentation(value as! UIImage, 0.3)!
//                    multipartFormData.append(imageData, withName: key as! String, fileName: "swift_file.jpg", mimeType: "image/*")
//                }else if value is NSURL || value is URL {
//                    let videoData:Data
//                    do {
//                        videoData = try Data (contentsOf: (value as! URL), options: .mappedIfSafe)
//                        multipartFormData.append(videoData, withName: key as! String, fileName: "swift_file.mp4", mimeType: "video/*")
//                    } catch {
//                        print(error)
//                        return
//                    }
//                }else if value is NSArray || value is NSMutableArray {
//                    for childValue in value as! NSArray
//                    {
//                        if childValue is UIImage {
//                            let imageData:Data = UIImageJPEGRepresentation(childValue as! UIImage, 0.3)!
//                            multipartFormData.append(imageData, withName: key as! String, fileName: "swift_file.jpg", mimeType: "image/*")
//                        }
//                    }
//                }
//                else {
//                    let valueData:Data = (value as! NSString).data(using: String.Encoding.utf8.rawValue)!
//                    multipartFormData.append(valueData, withName: key as! String)
//                }
//            }
//
//        }, to: endpointurl) { encodingResult in
//
//            ShowNetworkIndicator(xx: false)
//
//            switch encodingResult {
//            case .success(let upload, _, _):
//
//                upload.uploadProgress(closure: { (progress) in
//                    //if isUploading && isForeground {
//                    //self.delegate?.didReceivedProgress(progress: Float(progress.fractionCompleted))
//                    //}
//                })
//
//                upload.responseString(completionHandler: { (resp) in
//                    //print("RESP : \(resp)")
//                })
//
//                upload.responseJSON { response in
//                    ////print(response)
//                    switch(response.result) {
//                    case .success(_):
//                        if let data = response.result.value
//                        {
//                            self.Message = (data as! NSDictionary)[WSMESSAGE].asStringOrEmpty()
//                            let responseStatus = (data as! NSDictionary)[WSSUCCESS].asStringOrEmpty()
//                            switch (responseStatus) {
//
//                            case RESPONSE_STATUS.VALID.rawValue :
//                                self.resObjects = (data as! NSDictionary) as AnyObject
//                                break
//
//                            case RESPONSE_STATUS.INVALID.rawValue :
//                                self.resObjects = nil
//                                break
//
//                            default :
//                                break
//                            }
//                            responseData(self.resObjects, nil, self.Message)
//                        }
//                        break
//
//                    case .failure(_):
//                        responseData(nil, response.result.error as NSError?,MESSAGE)
//                        break
//
//                    }
//                }
//            case .failure( _):
//                responseData(nil, nil, MESSAGE)
//            }
//        }
//    }
}

public func ShowNetworkIndicator(xx :Bool)
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = xx
}

public func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
        }.resume()
}


//
//  LaunchScreenVC.swift
//  FoodScan
//
//  Created by C110 on 13/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import SwiftyJSON

class LaunchScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
//    func refreshTokenCall(){
//        let param:NSMutableDictionary = [
//            WS_KAccess_key:KNousername,
//           ]
//        param .addEntries(from: includeSecurityCredentials() as! [AnyHashable : Any])
//        
//        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIRefreshToken, parameters: param, encodingType:URL_ENCODING, responseData: { (response, error, message) in
//            
//            if response != nil
//            {
//                let objData = JSON(response!)[WSDATA].dictionary
//                if objData!["user"]!.array? .count != 0 {
//                    APP_DELEGATE.objUser = objData!["user"]!.array?.first?.to(type: WSUser.self) as? User
//                    let dic = (response as! NSDictionary).object(forKey: WSDATA) as! NSDictionary
////                    CoreDataAdaptor.sharedDataAdaptor.saveUserDetail(array: dic.object(forKey: "user") as! NSArray)
////
////                    UserDefaults.standard.set(true, forKey: kLogIn)
////                    UserDefaults.standard.set(objData!["UserToken"]!.string, forKey: kUserToken)
////                    UserDefaults.standard.set(APP_DELEGATE.objUser?.guid, forKey: kUserGUID)
////                    UserDefaults.standard.setCustomObjToUserDefaults(CustomeObj: APP_DELEGATE.objUser!, forKey: WSUSER)
////                    self.pushViewController(Storyboard: StoryBoardTab, ViewController: idTabVC, animation: true)
////                    APP_DELEGATE.socketIOHandler=SocketIOHandler()
//                }
//            }else {
//                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
//            }
//            
//            
//        })
//    }
}

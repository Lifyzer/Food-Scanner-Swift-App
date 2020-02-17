//
//  UIViewController.swift
//  Bazinga
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
var isCallAPI = false
import StoreKit
import SwiftyJSON


extension UIViewController
{
    //MARK: Rate to app on app store
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + APPID) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func generateRatingAlert(){
        let alert = UIAlertController(title: APPNAME, message: "Thanks for using app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remind me later", style: .default, handler: { (action) in
            UserDefaults.standard.set(true, forKey: IS_RATE_REMIND_LATER)
        }))
        alert.addAction(UIAlertAction(title: "Rate now", style: .default, handler: { (action) in
            UserDefaults.standard.set(false, forKey: IS_RATE_REMIND_LATER)
            self.rateApp()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func pushViewController(Storyboard:String,ViewController:String, animation:Bool)
    {
        let storyBoard = UIStoryboard(name: Storyboard, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: ViewController)
        APP_DELEGATE.mainNavigationController?.pushViewController(vc, animated: animation)
    }

    func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
            
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
            return topViewController(base: base)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    //MARK:- Activity
    func showIndicator(view: UIView) {
        let container: UIView = UIView()
        container.tag = 555
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3022527825)

        activityIndicator.frame = CGRect (x: 0, y: 0, width: 80, height: 80)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = container.center
        activityIndicator.hidesWhenStopped = true

        DispatchQueue.main.async {
            container.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            view.addSubview(container)
        }
    }

    func hideIndicator(view: UIView) {
        DispatchQueue.main.async {
            view.viewWithTag(555)?.removeFromSuperview()
        }
    }
    func generateAlertWithOkButton(text:String)
    {
        let alert = UIAlertController(title: APPNAME, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //Add/Remove product to favourite
    typealias MethodHandler1 = () -> Void
    func AddRemoveFromFavouriteAPI(isFavourite : String,product_id: String,fn:@escaping MethodHandler1)
    {
        if Connectivity.isConnectedToInternet
        {
                let userToken = UserDefaults.standard.string(forKey: kTempToken)
                let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
                let param:NSMutableDictionary = [
                    WS_KProduct_id:product_id,
                    WS_KIs_favourite:isFavourite,
                    WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? ""]
                
                print(param);
            
                includeSecurityCredentials {(data) in
                    let data1 = data as! [AnyHashable : Any]
                    param.addEntries(from: data1)
                }
                showIndicator(view: self.view)
                HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddToFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
                    self.hideIndicator(view: self.view)
                    if response != nil
                    {
                        let is_rate = JSON(response!)["is_rate"]
                        if is_rate == true {
                            self.generateRatingAlert()
                        }
                        fn()
                        SHOW_ALERT_VIEW(TITLE: "", DESC: message!, STATUS: .info, TARGET: self)
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
}

public func loadViewController(Storyboard:String,ViewController:String) -> UIViewController
{
    let storyBoard = UIStoryboard(name: Storyboard, bundle: nil)
    let vc = storyBoard.instantiateViewController(withIdentifier: ViewController)
    return vc
}


//
//  UIViewController.swift
//  Bazinga
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit

extension UIViewController
{
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
    
    
    //Add/Remove product to favourite
    func AddRemoveFromFavouriteAPI(isFavourite : String,product_id: String)
    {
        let userToken = UserDefaults.standard.string(forKey: kTempToken)
        let encodeString = FBEncryptorAES.encryptBase64String(APP_DELEGATE.objUser?.guid, keyString:  UserDefaults.standard.string(forKey: kGlobalPassword) ?? "", keyIv: UserDefaults.standard.string(forKey: KKey_iv) ?? "", separateLines: false)
        let param:NSMutableDictionary = [
            WS_KProduct_id:product_id,
            WS_KIs_favourite:isFavourite,
            WS_KUser_id:UserDefaults.standard.string(forKey: kUserId) ?? "",
            WS_KAccess_key:DEFAULT_ACCESS_KEY,
            WS_KSecret_key:userToken ?? ""]
        showIndicator(view: self.view)
        HttpRequestManager.sharedInstance.postJSONRequest(endpointurl: APIAddToFavourite, parameters: param, encodingType:JSON_ENCODING, responseData: { (response, error, message) in
            self.hideIndicator(view: self.view)
            if response != nil
            {
                showBanner(title: "", subTitle: message!, bannerStyle:.danger)
            }else {
                showBanner(title: "", subTitle: message!, bannerStyle: .danger)
            }
        })
    }
}

public func loadViewController(Storyboard:String,ViewController:String) -> UIViewController
{
    let storyBoard = UIStoryboard(name: Storyboard, bundle: nil)
    let vc = storyBoard.instantiateViewController(withIdentifier: ViewController)
    return vc
}


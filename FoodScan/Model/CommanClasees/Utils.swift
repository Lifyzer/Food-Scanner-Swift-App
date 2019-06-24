//
//  Utils.swift
//  Bazinga
//
//  Created by Narola C237 on 10/23/16.
//  Copyright © 2016 Narola C237. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

public func SCREENWIDTH() -> CGFloat
{
    return UIScreen.main.bounds.size.width
}

public func SCREENHEIGHT() -> CGFloat
{
    return UIScreen.main.bounds.size.height
}

public func showNetworkIndicator(xx:Bool)
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = xx
}

func SHOW_ALERT_VIEW(TITLE:String,DESC:String,STATUS:ISAlertType,TARGET:UIViewController){
    ISMessages.showCardAlert(withTitle: TITLE, message: DESC, duration: 2, hideOnSwipe: true, hideOnTap: true, alertType: STATUS, alertPosition: .bottom) { (true) in
    }
    if(STATUS == .error){
        UIDevice.vibrate()
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

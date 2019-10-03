//
//  NotificationBannerSwiftHandler.swift
//  Swing
//
//  Created by C110 on 21/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation
import NotificationBannerSwift



func showBanner(title:String,subTitle:String,bannerStyle:BannerStyle)
{
    let banner = NotificationBanner(title: title, subtitle: subTitle, style: bannerStyle)
    banner.autoDismiss = true
    banner.duration = 2

//    let lbl = UITextView()//UILabel()
//    lbl.font = UIFont(name: "Halvetica", size: 17)
////    lbl.lineBreakMode = .byWordWrapping
//    lbl.text = subTitle
////    lbl.frame.size.width = UIScreen.main.bounds.width
////    lbl.sizeToFit()
//    lbl.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
////    lbl.numberOfLines = 0
////    lbl.sizeToFit()

//    banner.bannerHeight = lbl.contentSize.height + 100
    banner.show()
}


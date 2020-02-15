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
    banner.show()
}


//
//  Utils.swift
//  Bazinga
//
//  Created by Narola C237 on 10/23/16.
//  Copyright © 2016 Narola C237. All rights reserved.
//

import Foundation
import UIKit

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

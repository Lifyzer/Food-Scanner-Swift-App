//
//  UIButton.swift
//  Bazinga
//
//  Created by C110 on 20/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

extension UIButton {

    func shakeUIButton()
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    func addTextSpacing(spacing: CGFloat) {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key,
                                      value: spacing,
                                      range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

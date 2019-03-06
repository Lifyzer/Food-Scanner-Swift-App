//
//  UITextField.swift
//  Bazinga
//
//  Created by C110 on 15/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
import AudioToolbox

extension UITextField
{
    func addLeftImage(image:UIImage,width:Double,height:Double)
    {
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageView.contentMode = .scaleAspectFit
        self.leftViewMode = UITextField.ViewMode.always
        self.leftView = imageView
        self.addSubview(imageView)
    }
    
    func shakeTextField()
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
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    

    func setLeftPaddingPoints(_ amount:CGFloat){
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
    }   
    
    
}

//
//  Design.swift
//  Hand-Hygiene
//
//  Created by MacBook on 3/9/18.
//  Copyright © 2018 SiliconOrchard. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)

    enum ViewSide {
        case Left, Right, Top, Bottom
    }

    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {

        let border = CALayer()
        border.backgroundColor = color

        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }

        layer.addSublayer(border)
    }
}


//#if canImport(UIKit) && !os(watchOS)
//
//// MARK: - Properties
//public extension UIButton {
//
//    /// SwifterSwift: Image of disabled state for button; also inspectable from Storyboard.
//    @IBInspectable public var imageForDisabled: UIImage? {
//        get {
//            return image(for: .disabled)
//        }
//        set {
//            setImage(newValue, for: .disabled)
//        }
//    }
//
//    /// SwifterSwift: Image of highlighted state for button; also inspectable from Storyboard.
//    @IBInspectable public var imageForHighlighted: UIImage? {
//        get {
//            return image(for: .highlighted)
//        }
//        set {
//            setImage(newValue, for: .highlighted)
//        }
//    }
//
//    /// SwifterSwift: Image of normal state for button; also inspectable from Storyboard.
//    @IBInspectable public var imageForNormal: UIImage? {
//        get {
//            return image(for: .normal)
//        }
//        set {
//            setImage(newValue, for: .normal)
//        }
//    }
//
//    /// SwifterSwift: Image of selected state for button; also inspectable from Storyboard.
//    @IBInspectable public var imageForSelected: UIImage? {
//        get {
//            return image(for: .selected)
//        }
//        set {
//            setImage(newValue, for: .selected)
//        }
//    }
//
//    /// SwifterSwift: Title color of disabled state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleColorForDisabled: UIColor? {
//        get {
//            return titleColor(for: .disabled)
//        }
//        set {
//            setTitleColor(newValue, for: .disabled)
//        }
//    }
//
//    /// SwifterSwift: Title color of highlighted state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleColorForHighlighted: UIColor? {
//        get {
//            return titleColor(for: .highlighted)
//        }
//        set {
//            setTitleColor(newValue, for: .highlighted)
//        }
//    }
//
//    /// SwifterSwift: Title color of normal state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleColorForNormal: UIColor? {
//        get {
//            return titleColor(for: .normal)
//        }
//        set {
//            setTitleColor(newValue, for: .normal)
//        }
//    }
//
//    /// SwifterSwift: Title color of selected state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleColorForSelected: UIColor? {
//        get {
//            return titleColor(for: .selected)
//        }
//        set {
//            setTitleColor(newValue, for: .selected)
//        }
//    }
//
//    /// SwifterSwift: Title of disabled state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleForDisabled: String? {
//        get {
//            return title(for: .disabled)
//        }
//        set {
//            setTitle(newValue, for: .disabled)
//        }
//    }
//
//    /// SwifterSwift: Title of highlighted state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleForHighlighted: String? {
//        get {
//            return title(for: .highlighted)
//        }
//        set {
//            setTitle(newValue, for: .highlighted)
//        }
//    }
//
//    /// SwifterSwift: Title of normal state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleForNormal: String? {
//        get {
//            return title(for: .normal)
//        }
//        set {
//            setTitle(newValue, for: .normal)
//        }
//    }
//
//    /// SwifterSwift: Title of selected state for button; also inspectable from Storyboard.
//    @IBInspectable public var titleForSelected: String? {
//        get {
//            return title(for: .selected)
//        }
//        set {
//            setTitle(newValue, for: .selected)
//        }
//    }
//
//}
//
//// MARK: - Methods
//public extension UIButton {
//
//    private var states: [UIControlState] {
//        return [.normal, .selected, .highlighted, .disabled]
//    }
//
//    /// SwifterSwift: Set image for all states.
//    ///
//    /// - Parameter image: UIImage.
//    public func setImageForAllStates(_ image: UIImage) {
//        states.forEach { self.setImage(image, for: $0) }
//    }
//
//    /// SwifterSwift: Set title color for all states.
//    ///
//    /// - Parameter color: UIColor.
//    public func setTitleColorForAllStates(_ color: UIColor) {
//        states.forEach { self.setTitleColor(color, for: $0) }
//    }
//
//    /// SwifterSwift: Set title for all states.
//    ///
//    /// - Parameter title: title string.
//    public func setTitleForAllStates(_ title: String) {
//        states.forEach { self.setTitle(title, for: $0) }
//    }
//
//    /// SwifterSwift: Center align title text and image on UIButton
//    ///
//    /// - Parameter spacing: spacing between UIButton title text and UIButton Image.
//    public func centerTextAndImage(spacing: CGFloat) {
//        let insetAmount = spacing / 2
//        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
//        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
//        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
//    }
//
//}
//#endif

extension UIButton {
    func selectedButton(title:String, iconName: String, widthConstraints: NSLayoutConstraint){

        self.backgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setImage(UIImage(named: iconName), for: .normal)
        self.setImage(UIImage(named: iconName), for: .highlighted)
        let imageWidth = self.imageView!.frame.width
       // let textWidth = (title as NSString).size(attributes:[NSFontAttributeName:self.titleLabel!.font!]).width

        let textWidth = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font!]).width
        let width = textWidth + imageWidth + 24

        //24 - the sum of your insets from left and right
        widthConstraints.constant = width
        self.layoutIfNeeded()
    }
}

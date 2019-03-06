//
//  UITextView.swift
//  Bazinga
//
//  Created by C110 on 20/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
import Foundation

extension UITextView: UITextViewDelegate
{
    
}

open class NISLTextView : UITextView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: Notification.Name.UITextView.textDidChangeNotification, object: self)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: Notification.Name.UITextView.textDidChangeNotification, object: self)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder), name: Notification.Name.UITextView.textDidChangeNotification, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var placeholderLabel: UILabel?
    
    /** @abstract To set textView's placeholder text. Default is ni.    */
    @IBInspectable open var placeholder : String? {
        
        get {
            return placeholderLabel?.text
        }
        
        set {
            
            if placeholderLabel == nil {
                
                placeholderLabel = UILabel()
                
                if let unwrappedPlaceholderLabel = placeholderLabel {
                    
                    unwrappedPlaceholderLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    unwrappedPlaceholderLabel.lineBreakMode = .byWordWrapping
                    unwrappedPlaceholderLabel.numberOfLines = 0
                    unwrappedPlaceholderLabel.font = self.font
                    unwrappedPlaceholderLabel.textAlignment = self.textAlignment
                    unwrappedPlaceholderLabel.backgroundColor = UIColor.clear
                    unwrappedPlaceholderLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
                    unwrappedPlaceholderLabel.alpha = 0
                    addSubview(unwrappedPlaceholderLabel)
                }
            }
            
            placeholderLabel?.text = newValue
            refreshPlaceholder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let unwrappedPlaceholderLabel = placeholderLabel {
            
            let offsetLeft = textContainerInset.left + textContainer.lineFragmentPadding
            let offsetRight = textContainerInset.right + textContainer.lineFragmentPadding
            let offsetTop = textContainerInset.top
            let offsetBottom = textContainerInset.top
            
            let expectedSize = unwrappedPlaceholderLabel.sizeThatFits(CGSize(width: self.frame.width-offsetLeft-offsetRight, height: self.frame.height-offsetTop-offsetBottom))
            
            unwrappedPlaceholderLabel.frame = CGRect(x: offsetLeft, y: offsetTop, width: expectedSize.width, height: expectedSize.height)
        }
    }
    
    @objc open func refreshPlaceholder() {
        
        if text.count != 0 {
            placeholderLabel?.alpha = 0
        } else {
            placeholderLabel?.alpha = 1
        }
    }
    
    override open var text: String! {
        
        didSet {
            
            refreshPlaceholder()
            
        }
    }
    
    override open var font : UIFont? {
        
        didSet {
            
            if let unwrappedFont = font {
                placeholderLabel?.font = unwrappedFont
            } else {
                placeholderLabel?.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
    
    override open var textAlignment: NSTextAlignment
        {
        didSet {
            placeholderLabel?.textAlignment = textAlignment
        }
    }
    
    override open var delegate : UITextViewDelegate? {
        
        get {
            refreshPlaceholder()
            return super.delegate
        }
        
        set {
            super.delegate = newValue
        }
    }
}





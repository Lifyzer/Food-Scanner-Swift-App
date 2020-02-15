//
//  UISearchBar+Extensions.swift
//  Bazinga
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {

    private func getViewElement<T>(type: T.Type) -> T? {
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }

    func getSearchBarTextField() -> UITextField? {
        return getViewElement(type: UITextField.self)
    }

    func setTextColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }

    func setTextFieldColor(color: UIColor) {
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6

            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }

    func setPlaceholderTextColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }

    func setTextFieldClearButtonColor(color: UIColor) {
        if let textField = getSearchBarTextField() {
            let button = textField.value(forKey: "clearButton") as! UIButton
            if let image = button.imageView?.image {
            }
        }
    }

    func setSearchImageColor(color: UIColor) {
        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
        }
    }

}

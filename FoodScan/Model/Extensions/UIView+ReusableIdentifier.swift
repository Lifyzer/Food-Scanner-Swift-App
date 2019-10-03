//
//  UIView+ReusableIdentifier.swift
//  Bazinga
//
//  Created by C110 on 27/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit

protocol ReuseIdentifier {

  static var reuseIdentifier: String { get }

}

extension ReuseIdentifier {

  /// Return a suggested name that can be used as an cellIdentifier.
  static var reuseIdentifier: String {
    return String(describing: self)
  }

}

extension UICollectionViewCell: ReuseIdentifier {}
extension UITableViewCell: ReuseIdentifier {}
extension UITableViewHeaderFooterView: ReuseIdentifier {}

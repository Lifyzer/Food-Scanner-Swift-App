//
//  UIView+Nib.swift
//  zentimer
//
//  Created by Craig Zheng on 31/10/17.
//

import UIKit

extension UIView {

  /// Return an UINib object from the nib file with the same name.
  class var nib: UINib? {
    return UINib(nibName: String(describing: self), bundle: nil)
  }

  class var viewFromNib: UIView? {
    let views = Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)
    let view = views![0] as! UIView
    return view
  }

}

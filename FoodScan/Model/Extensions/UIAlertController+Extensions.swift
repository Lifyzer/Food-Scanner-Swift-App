//
//  UIAlertController+Extensions.swift
//  Bazinga
//
//  Created by C110 on 06/01/18.
//

import Foundation
import UIKit

extension UIAlertController
{

}


public func showAlert(Title:String,Message:String,delegate:UIViewController)
{
    let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    delegate.present(alert, animated: true, completion: nil)
}

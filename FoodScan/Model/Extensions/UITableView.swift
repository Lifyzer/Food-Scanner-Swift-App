//
//  UITableView.swift
//  Hi-Shoppers
//
//  Created by NC2-28 on 03/01/18.
//  Copyright © 2018 NC2-28. All rights reserved.
//

import Foundation
import UIKit
extension UITableView {
    func indexPathForView(_ view: UIView) -> IndexPath? {
        let origin = view.bounds.origin
        let viewOrigin = self.convert(origin, from: view)
        let indexPath = self.indexPathForRow(at: viewOrigin)
        return indexPath
    }
    func setTableViewRowHeightDynamic(rowHeight:CGFloat)  {
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = rowHeight
    }
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.semibold)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
    }
    func restore() {
        self.backgroundView = nil
    }
    
    func addLoaderView() {
        let frame = self.frame
        let loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.center = loader.center
        loader.startAnimating()
        loader.color = UIColor.black
        self.backgroundView = loader;
        self.frame = frame
    }
    
    func registerForLoadMore() {
        let headerNib = UINib(nibName: "LoadMoreCell", bundle: nil)
        self.register(headerNib, forCellReuseIdentifier: "LoadMoreCell")
    }
    func addPullRefresh(target : Any?, attachedSelector : Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        self.alwaysBounceVertical = true
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(target, action: attachedSelector, for: .valueChanged)
        self.addSubview(refreshControl)
        return refreshControl
    }
}


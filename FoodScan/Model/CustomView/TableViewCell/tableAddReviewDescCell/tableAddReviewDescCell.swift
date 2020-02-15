//
//  tableAddReviewDescCell.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class tableAddReviewDescCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var viewDescription: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewDescription.layer.cornerRadius = 5.0
        viewDescription.layer.borderWidth = 0.5
        viewDescription.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

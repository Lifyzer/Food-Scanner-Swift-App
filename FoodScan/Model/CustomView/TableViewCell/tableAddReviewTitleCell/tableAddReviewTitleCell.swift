//
//  tableAddReviewTitleCell.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class tableAddReviewTitleCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var viewTitle: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewTitle.layer.cornerRadius = 5.0
        viewTitle.layer.borderWidth = 0.5
        viewTitle.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

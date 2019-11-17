//
//  tableAddReviewProductDetailsCell.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import Cosmos

class tableAddReviewProductDetailsCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewRatting: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewRatting.settings.fillMode = .half

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

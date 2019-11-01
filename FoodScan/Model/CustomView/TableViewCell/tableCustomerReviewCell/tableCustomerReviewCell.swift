//
//  tableCustomerReviewCell.swift
//  FoodScan
//
//  Created by C100-169 on 01/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import Cosmos

class tableCustomerReviewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnWriteReview: UIButton!
    @IBOutlet weak var viewRatting: CosmosView!
    @IBOutlet weak var lblReviewDetails: UILabel!
    @IBOutlet weak var lblTotalReviews: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

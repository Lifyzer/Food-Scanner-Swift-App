//
//  tableUserReviewCell.swift
//  FoodScan
//
//  Created by C100-169 on 02/11/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
import Cosmos

class tableUserReviewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblReviewUserName: UILabel!
    @IBOutlet weak var lblReviewTime: UILabel!
    @IBOutlet weak var viewRatting: CosmosView!
    @IBOutlet weak var lblReviewDate: UILabel!
    @IBOutlet weak var lblReviewTitle: UILabel!
    @IBOutlet weak var lblReviewDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewRatting.settings.fillMode = .half
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

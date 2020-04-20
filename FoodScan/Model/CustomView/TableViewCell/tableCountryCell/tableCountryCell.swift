//
//  tableCountryCell.swift
//  FoodScan
//
//  Created by Admin on 20/04/20.
//  Copyright © 2020 C110. All rights reserved.
//

import UIKit

class tableCountryCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelection: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSelection.setImage(#imageLiteral(resourceName: "country_selected"), for: .selected)
        btnSelection.setImage(UIImage(), for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

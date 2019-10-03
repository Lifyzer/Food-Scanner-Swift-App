//
//  tableSettingsCell.swift
//  newswise
//
//  Created by C110 on 16/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableSettingsCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var txtKeyword : UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

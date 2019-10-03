//
//  tableNotificationCell.swift
//  newswise
//
//  Created by C110 on 13/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableNotificationCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnArrow: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var subNote: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


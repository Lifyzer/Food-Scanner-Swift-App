//
//  tableLatestNewsCell.swift
//  newswise
//
//  Created by C110 on 13/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableProfileCell : UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

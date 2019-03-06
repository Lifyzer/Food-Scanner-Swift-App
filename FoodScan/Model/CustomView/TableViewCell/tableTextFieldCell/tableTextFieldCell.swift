//
//  tableTextFieldCell.swift
//  Bazinga
//
//  Created by C110 on 14/05/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableTextFieldCell: UITableViewCell {

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  tableMenuListCell.swift
//  newswise
//
//  Created by C110 on 12/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableFoodCell: UITableViewCell{
    
    @IBOutlet weak var imgFood: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var productType: UIButton!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var labelDate: UILabel!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
   
}

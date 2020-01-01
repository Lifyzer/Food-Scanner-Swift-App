//
//  tableMenuListCell.swift
//  newswise
//
//  Created by C110 on 12/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit
import Cosmos

class tableFoodCell: UITableViewCell{

    @IBOutlet weak var tableDetailsHeight: NSLayoutConstraint!
    @IBOutlet weak var imgFavouriteFood: UIImageView!
    @IBOutlet weak var imgFood: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var lblDetailsHeight: NSLayoutConstraint!
    @IBOutlet weak var productType: UIButton!

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var viewRatting: CosmosView!
    
    @IBOutlet weak var tableProducts: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
       

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }


}

//
//  tableNewsDetailCell.swift
//  newswise
//
//  Created by C110 on 17/07/18.
//  Copyright © 2018 C110. All rights reserved.
//

import UIKit

class tableNewsDetailCell: UITableViewCell {

    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var labelImageDesc: UILabel!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
           
            self.pageControl.contentHorizontalAlignment = .right
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
        }
    }
    
    fileprivate var styleIndex = 0 {
        didSet {
            // Clean up
            self.pageControl.setStrokeColor(nil, for: .normal)
            self.pageControl.setStrokeColor(nil, for: .selected)
            self.pageControl.setFillColor(nil, for: .normal)
            self.pageControl.setFillColor(nil, for: .selected)
            self.pageControl.setImage(nil, for: .normal)
            self.pageControl.setImage(nil, for: .selected)
            self.pageControl.setPath(nil, for: .normal)
            self.pageControl.setPath(nil, for: .selected)
            switch self.styleIndex {
            case 0:
                // Default
                break
            case 1:
                // Ring
                self.pageControl.setStrokeColor(.green, for: .normal)
                self.pageControl.setStrokeColor(.green, for: .selected)
                self.pageControl.setFillColor(.green, for: .selected)
            case 2:
                // Image
                self.pageControl.setImage(UIImage(named:"icon_footprint"), for: .normal)
                self.pageControl.setImage(UIImage(named:"icon_cat"), for: .selected)
            
            default:
                break
            }
        }
    }
    fileprivate var alignmentIndex = 0 {
        didSet {
            self.pageControl.contentHorizontalAlignment = [.right,.center,.left][self.alignmentIndex]
        }
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var cvTagView: UICollectionView!
   
    @IBOutlet weak var buttonAddToFav: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonComment: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var labledContent: UILabel!
    
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
   
     @IBOutlet weak var buttonFb: UIButton!
     @IBOutlet weak var buttonTwitter: UIButton!
     @IBOutlet weak var buttonInsta: UIButton!
     @IBOutlet weak var buttonLinkedin: UIButton!
     @IBOutlet weak var buttonWhatsapp: UIButton!
     @IBOutlet weak var buttonGplus: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.txtMessage.delegate = self as? UITextViewDelegate
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   

}

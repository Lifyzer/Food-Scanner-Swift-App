//
//  FoodDetailVC.swift
//  FoodScan
//
//  Created by C110 on 16/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit
let iDtableFoodCell = "tableFoodCell"

class FoodDetailVC: UIViewController {
    @IBOutlet var tableDetails: UITableView!
    @IBOutlet var tableSubDetails: UITableView!
    @IBOutlet var lblProduct: UILabel!
    @IBOutlet var btnFav: UIButton!
    @IBOutlet var btnCategory: UIButton!
    @IBOutlet var vwHeader : UIView!
    var objProduct : WSProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableDetails.tableHeaderView = vwHeader
        lblProduct.text = objProduct.productName
        let isHealthy : String = objProduct.isHealthy ?? ""
        if isHealthy != "" && isHealthy.count > 0{
            if isHealthy == "0" {
                btnCategory.setTitle("\(Poor)", for: .normal)
                btnCategory.setTitleColor(UIColor(red:  230/255, green: 0/255, blue: 20/255, alpha: 1.0), for: .normal)
                btnCategory.setImage(UIImage(named: "dot_red_small"), for: .normal)
            }else {
                btnCategory.setTitle("Excellent", for: .normal)
                btnCategory.setTitleColor(UIColor(red:  85/255, green: 165/255, blue: 70/255, alpha: 1.0), for: .normal)
                btnCategory.setImage(UIImage(named: "dot_green_small"), for: .normal)
            }
        }
        let isFav : String = objProduct.isFavourite ?? ""
        if isFav == "0"{
             btnFav.setImage(UIImage(named: "unfav_white_icon"), for: .normal)
        }else {
             btnFav.setImage(UIImage(named: "fav_white_icon"), for: .normal)
        }
       
        // Do any additional setup after loading the view.
    }
    enum SubDetailsItems: Int {
        case Protein=0 , Sugar, Salt, Ingredients, Fat, Calories, SaturatedFats, Carbohydrate, DietaryFiber
        case totalCount = 9
    }
    
    

    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- Table - Delegate - DataSource
extension FoodDetailVC: UITableViewDelegate,UITableViewDataSource {
    
    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return SubDetailsItems.totalCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "food_details_cell", for: indexPath) as! tableFoodCell
            cell.selectionStyle = .none
        switch indexPath.row {
        case SubDetailsItems.Protein.rawValue:
            cell.productName.text = "Protein"
            cell.productType .setTitle(objProduct.protein, for: .normal)
            break;
        case SubDetailsItems.Sugar.rawValue:
            cell.productName.text = "Sugar"
            cell.productType .setTitle(objProduct.sugar, for: .normal)
            cell.imgFood.setImage(UIImage(named: "dot_red_small"), for: .normal)
            break;
        case SubDetailsItems.Salt.rawValue:
            cell.productName.text = "Salt"
            cell.productType .setTitle(objProduct.salt, for: .normal)
            break;
        case SubDetailsItems.Ingredients.rawValue:
            cell.productName.text = "Ingredients"
            cell.productType .setTitle(objProduct.ingredients, for: .normal)
            break;
        case SubDetailsItems.Fat.rawValue:
            cell.productName.text = "Fat"
            cell.productType .setTitle(objProduct.fatAmount, for: .normal)
            break;
        case SubDetailsItems.Calories.rawValue:
            cell.productName.text = "Calories"
            cell.productType .setTitle(objProduct.calories, for: .normal)
            break;
        case SubDetailsItems.SaturatedFats.rawValue:
            cell.productName.text = "Saturated Fats"
            cell.productType .setTitle(objProduct.saturatedFats, for: .normal)
            break;
        case SubDetailsItems.Carbohydrate.rawValue:
            cell.productName.text = "Carbohydrate"
            cell.productType .setTitle(objProduct.carbohydrate, for: .normal)
            break;
        case SubDetailsItems.DietaryFiber.rawValue:
            cell.productName.text = "Dietary Fiber"
            cell.productType .setTitle(objProduct.dietaryFiber, for: .normal)
            break;
        default:
            break;
        }
        return cell
    }
   
}

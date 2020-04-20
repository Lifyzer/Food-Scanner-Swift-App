//
//  SelectCountryVC.swift
//  FoodScan
//
//  Created by Admin on 20/04/20.
//  Copyright © 2020 C110. All rights reserved.
//

import UIKit

@objc protocol CountryPopupDelegate {
    func selectedCountry(index:Int)
}
var arrCountryImages = [#imageLiteral(resourceName: "country_eu"),#imageLiteral(resourceName: "country_us"),#imageLiteral(resourceName: "country_swiss")]

class SelectCountryVC: UIViewController{

    @IBOutlet weak var tableCountry: UITableView!
    
    var arrCountry = ["EU market","US market","Swiss market"]
    var delegate : CountryPopupDelegate?
    var selectedCountry = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Functions
    func setupUI(){
            tableCountry.register(tableCountryCell.nib, forCellReuseIdentifier: tableCountryCell.reuseIdentifier)
    }

}
extension SelectCountryVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCountryCell.reuseIdentifier, for: indexPath) as! tableCountryCell
        cell.lblTitle.text = arrCountry[indexPath.row]
        cell.img.image = arrCountryImages[indexPath.row]
        cell.btnSelection.isUserInteractionEnabled = false
        if selectedCountry == indexPath.row{
            cell.btnSelection.isSelected = true
        }else{
            cell.btnSelection.isSelected = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CountryHeight)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = indexPath.row
        tableCountry.reloadData()
        UserDefaults.standard.set(selectedCountry, forKey: KFoodType)
        delegate?.selectedCountry(index: indexPath.row)
    }
    
}

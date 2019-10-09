//
//  SettingsVC.swift
//  FoodScan
//
//  Created by C110 on 12/02/19.
//  Copyright © 2019 C110. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    enum SettingsItems: Int {
        case EditProfile = 0 , ChangePassword, TermsCondition
        case totalCount = 3
    }
    @IBOutlet var tableSettings: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableSettings.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonSignOutClicked(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: kLogIn)
        UserDefaults.standard.removeObject(forKey: KUser)
        UserDefaults.standard.removeObject(forKey: kUserName)
        UserDefaults.standard.removeObject(forKey: kUserId)
        UserDefaults.standard.removeObject(forKey: KScanOption)

            self.navigationController?.popViewController(animated: true)
    }

    @IBAction func buttonBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- Table - Delegate - DataSource
extension SettingsVC: UITableViewDelegate,UITableViewDataSource {

    //Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsItems.totalCount.rawValue;

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings_cell", for: indexPath) as! tableProfileCell
        switch indexPath.row {
        case SettingsItems.EditProfile.rawValue:
            cell.lblTitle.text = "Edit Profile"
            break

        case SettingsItems.ChangePassword.rawValue:
            cell.lblTitle.text = "Change Password"
            break

        case SettingsItems.TermsCondition.rawValue:
            cell.lblTitle.text = "Terms & Conditions"
            break

        default:
           break
        }

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {

        case SettingsItems.EditProfile.rawValue:
            pushViewController(Storyboard: StoryBoardSettings, ViewController: idEditProfileVC, animation: true)
            break

        case SettingsItems.ChangePassword.rawValue:
            pushViewController(Storyboard: StoryBoardSettings, ViewController: idChangePasswordVC, animation: true)
            break

        case SettingsItems.TermsCondition.rawValue:
            pushViewController(Storyboard: StoryBoardLogin, ViewController: idPrivacyPolicyVC, animation: true)
            break

        default:
            break
        }
    }
}




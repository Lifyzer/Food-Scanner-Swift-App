//
//  UserDefaults+Extensions.swift
//  Bazinga
//
//  Created by C110 on 22/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
import Foundation


extension UserDefaults {

    func setCustomObjToUserDefaults(CustomeObj: AnyObject, forKey:String) {
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: CustomeObj)
        defaults.set(encodedData, forKey: forKey)
        defaults.synchronize()
    }

    func getCustomObjFromUserDefaults(forKey:String) -> AnyObject? {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: forKey) != nil {
            let decoded  = defaults.object(forKey: forKey) as! NSData
            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data)! as AnyObject
            return decodedTeams
        }
        return nil
    }

    func removeCustomObject(forKey:String)
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: forKey)
        defaults.synchronize()
    }

}

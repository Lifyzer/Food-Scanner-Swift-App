//
//  Audio+Extensions.swift
//  Bazinga
//
//  Created by C110 on 27/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation
import AudioToolbox

public func playNewMessageSound() {
    AudioServicesPlaySystemSoundWithCompletion(1307){}
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) 
}

//
//  Device.swift
//  googlemap-clone
//
//  Created by Thang Tran on 6/15/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess
extension UIDevice {
    var uniqueDeviceIdentifier: String {
        let keychain = Keychain().accessibility(.Always)
        
        let keyName = "UniqueDeviceIdentifier"
        
        if let uniqueDeviceIdentifier = keychain[keyName] {
            return uniqueDeviceIdentifier
        } else {
            let uniqueDeviceIdentifier = NSUUID().UUIDString
            keychain[keyName] = uniqueDeviceIdentifier
            return uniqueDeviceIdentifier
        }
    }
}
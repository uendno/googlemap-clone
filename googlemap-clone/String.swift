//
//  String.swift
//  googlemap-clone
//
//  Created by Tran Viet Thang on 6/17/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func cropString(str: String) -> String {
        
        var length = str.characters.count
        if (length >= 30) {
            while (str.characters [str.startIndex.advancedBy(length-1)] != " ") {
                length = length - 1
            }
            
           return str.substringToIndex(str.startIndex.advancedBy(length-1))
        } else {
            return str
        }
        
    }
}

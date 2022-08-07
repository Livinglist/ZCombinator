//
//  Bool+Ext.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/6/22.
//

import Foundation
import UIKit

extension Bool {
     static var iOS16: Bool {
         guard #available(iOS 16.0, *) else {
             return false
         }

         return true
     }
 }

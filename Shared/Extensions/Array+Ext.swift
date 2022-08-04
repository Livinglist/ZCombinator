//
//  Array+Ext.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isMoreThanOne: Bool {
        guard let unwrapped = self else {
            return false
        }
        
        if unwrapped.count > 1 {
            return true
        } else {
            return false
        }
    }
    
    var countOrZero: Int {
        guard let unwrapped = self else {
            return 0
        }
        
        return unwrapped.count
    }
}

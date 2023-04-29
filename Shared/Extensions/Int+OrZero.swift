//
//  Int+OrZero.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 4/28/23.
//

import Foundation

extension Int?  {
    var orZero: Int {
        guard let unwrapped = self else {
            return 0
        }
        return unwrapped
    }
}

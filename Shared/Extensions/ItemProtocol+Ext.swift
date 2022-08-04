//
//  ItemProtocolExtensions.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation

extension ItemProtocol {
    var createdAt: String {
        let date = Date(timeIntervalSince1970: Double(time))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    var readableUrl: String? {
        if let url = self.url {
            let domain = URL(string: url)?.host
            return domain
        }
        return nil
    }
}

//
//  String+Ext.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation

extension Optional where Wrapped == String {
    var valueOrEmpty: String {
        guard let unwrapped = self else {
            return ""
        }
        return unwrapped
    }
    
    func htmlToString() -> String {
        guard let unwrapped = self else {
            return ""
        }
        
        return try! NSAttributedString(data: unwrapped.data(using: .utf8)!,
                                       options: [.documentType: NSAttributedString.DocumentType.html],
                                       documentAttributes: nil).string
    }
}

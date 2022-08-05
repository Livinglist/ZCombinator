//
//  String+Ext.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation

extension String {
    var htmlStripped: String {
        let res = try? NSAttributedString(data: self.data(using: .unicode)!,
                                       options: [.documentType: NSAttributedString.DocumentType.html],
                                       documentAttributes: nil).string
        return res ?? ""
    }
    
    var withExtraLineBreak: String {
        String(self.replacingOccurrences(of: "\n", with: "\n\n").dropLast(2))
    }
}

extension Optional where Wrapped == String {
    var valueOrEmpty: String {
        guard let unwrapped = self else {
            return ""
        }
        return unwrapped
    }
    
    var htmlStripped: String{
        guard let unwrapped = self else {
            return ""
        }
        
        return unwrapped.htmlStripped
    }
}

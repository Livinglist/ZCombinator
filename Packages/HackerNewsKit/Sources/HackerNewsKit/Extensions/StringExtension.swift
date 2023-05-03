import Foundation
import UIKit

public extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    var htmlStripped: String {
        guard let data = self.data(using: .utf8),
              let res = try? NSAttributedString(data: data,
                                                options: [.documentType: NSAttributedString.DocumentType.html],
                                                documentAttributes: nil).string else { return self }
        return res
    }
    
    var withExtraLineBreak: String {
        if isEmpty { return self }
        let range = startIndex..<index(endIndex, offsetBy: -1)
        var str = String(replacingOccurrences(of: "\n", with: "\n\n", range: range))
        while str.last?.isWhitespace == true {
            str = String(str.dropLast())
        }
        return str
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

public extension Optional where Wrapped == String {
    var orEmpty: String {
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
    
    var isNotNullOrEmpty: Bool {
        guard let unwrapped = self else {
            return false
        }
        
        return unwrapped.isNotEmpty
    }
}

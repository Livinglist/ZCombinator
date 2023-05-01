import Foundation

extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    var htmlStripped: String {
        let res = try? NSAttributedString(data: self.data(using: .unicode)!,
                                       options: [.documentType: NSAttributedString.DocumentType.html],
                                       documentAttributes: nil).string
        return res.orEmpty
    }
    
    var withExtraLineBreak: String {
        String(self.replacingOccurrences(of: "\n", with: "\n\n").dropLast(2))
    }
    
    var markdowned: AttributedString {
        // Regex matching URLs.
        let regex = try! NSRegularExpression(pattern: #"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"#)
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, range: range)
        var str = self
    
        for match in matches {
            let matchedString = String(self[Range(match.range, in: self)!])
            let display = "\(matchedString)"
            
            str = str.replacingOccurrences(of: matchedString, with: "[\(display)](\(matchedString))")
        }
        
        return try! AttributedString(
            markdown: str, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension Optional where Wrapped == String {
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

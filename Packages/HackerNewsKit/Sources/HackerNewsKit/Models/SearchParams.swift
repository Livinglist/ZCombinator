import Foundation

public class SearchParams {
    public let page: Int
    public let query: String
    public let sorted: Bool
    
    public var filteredQuery: String {
        var buffer = String()
        guard let encodedQuery = URLComponents(string: query)?.string.orEmpty else { return String() }
        
        if sorted {
            buffer.append("search_by_date?query=\(encodedQuery)")
        } else {
            buffer.append("search?query=?query=\(encodedQuery)")
        }
        
        buffer.append("&page=\(page)");
        
        return buffer
    }
    
    public init(page: Int, query: String, sorted: Bool) {
        self.page = page
        self.query = query
        self.sorted = sorted
    }
    
    public func copyWith(page: Int? = nil, query: String? = nil, sorted: Bool? = nil) -> SearchParams {
        return SearchParams(page: page ?? self.page, query: query ?? self.query, sorted: sorted ?? self.sorted)
    }
}

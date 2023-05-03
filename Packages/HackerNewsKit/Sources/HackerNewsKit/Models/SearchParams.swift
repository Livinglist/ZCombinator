import Foundation

public class SearchParams {
    public let page: Int
    public let query: String
    public let sorted: Bool
    public let filters: [any SearchFilter]
    
    public var filteredQuery: String {
        var buffer = String()
        guard let encodedQuery = URLComponents(string: query)?.string.orEmpty else { return String() }
        
        if sorted {
            buffer.append("search_by_date?query=\(encodedQuery)")
        } else {
            buffer.append("search?query=?query=\(encodedQuery)")
        }
        
        if filters.isEmpty == false {
            buffer.append("&tags=")
            
            for filter in filters {
                buffer.append(filter.query)
                buffer.append(",")
            }
            
            buffer = String(buffer.dropLast(1))
        }
        
        buffer.append("&page=\(page)");
        
        return buffer
    }
    
    public init(page: Int, query: String, sorted: Bool, filters: [any SearchFilter]) {
        self.page = page
        self.query = query
        self.sorted = sorted
        self.filters = filters
    }
    
    public func copyWith(page: Int? = nil, query: String? = nil, sorted: Bool? = nil, filters: [any SearchFilter]? = nil) -> SearchParams {
        return SearchParams(page: page ?? self.page, query: query ?? self.query, sorted: sorted ?? self.sorted, filters: filters ?? self.filters)
    }
}

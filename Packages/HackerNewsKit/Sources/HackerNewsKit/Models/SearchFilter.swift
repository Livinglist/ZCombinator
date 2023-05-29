import Foundation

public enum SearchFilter: Equatable, Hashable {
    case story
    case comment
    case dateRange(Date, Date)
    
    var query: String {
        switch(self){
        case .story:
            return "story"
        case .comment:
            return "comment"
        case .dateRange(let startDate, let endDate):
            let startTimestamp = startDate.timeIntervalSince1970
            let endTimestamp = endDate.timeIntervalSince1970
            if startTimestamp != endTimestamp {
                return "created_at_i>=\(startTimestamp), created_at_i<=\(endTimestamp)"
            } else {
                return "created_at_i=\(startTimestamp)"
            }
        }
    }
    
    var isNumericFilter: Bool {
        switch(self){
        case .story, .comment:
            return false
        case .dateRange:
            return true
        }
    }
    
    var isTagFilter: Bool {
        !isNumericFilter
    }
}

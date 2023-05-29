import Foundation

enum Filter: Equatable {
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
}

public protocol SearchFilter: Equatable {
    var query: String { get }
}

public class StoryFilter: SearchFilter {
    public let query: String = "story"

    public init() { }
    
    public static func == (lhs: StoryFilter, rhs: StoryFilter) -> Bool {
        lhs.query == rhs.query
    }
}

public class CommentFilter: SearchFilter {
    public let query: String = "comment"

    public init() { }
    
    public static func == (lhs: CommentFilter, rhs: CommentFilter) -> Bool {
        lhs.query == rhs.query
    }
}

public class DateRangeFilter: SearchFilter {
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public var query: String {
        let startTimestamp = startDate.timeIntervalSince1970
        let endTimestamp = endDate.timeIntervalSince1970
        if startTimestamp != endTimestamp {
            return "created_at_i>=\(startTimestamp), created_at_i<=\(endTimestamp)"
        } else {
            return "created_at_i=\(startTimestamp)"
        }
    }
    
    public static func == (lhs: DateRangeFilter, rhs: DateRangeFilter) -> Bool {
        lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
    }
}

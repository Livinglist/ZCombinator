public protocol SearchFilter: Equatable {
    var query: String { get }
}

public class StoryFilter: SearchFilter {
    public let query: String = "story"

    public static func == (lhs: StoryFilter, rhs: StoryFilter) -> Bool {
        lhs.query == rhs.query
    }

    public init() { }
}

public class CommentFilter: SearchFilter {
    public let query: String = "comment"

    public static func == (lhs: CommentFilter, rhs: CommentFilter) -> Bool {
        lhs.query == rhs.query
    }

    public init() { }
}

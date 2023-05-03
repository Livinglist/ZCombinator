public protocol SearchFilter {
    var query: String { get }
}

public class StoryFilter: SearchFilter {
    public let query: String = "story"
}

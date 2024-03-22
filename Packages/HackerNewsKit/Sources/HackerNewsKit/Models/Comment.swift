public struct Comment: Item {
    public let id: Int
    public let parent: Int?
    public let text: String?
    public var type: String? = "comment"
    public let by: String?
    public let score: Int?
    public let descendants: Int?
    public let time: Int
    public let kids: [Int]?
    public let level: Int?
    public var metadata: String {
        if let count = kids?.count, count != 0 {
            return "\(count) cmt\(count > 1 ? "s":"") | \(timeAgo) by \(by.orEmpty)"
        } else {
            return "\(timeAgo) by \(by.orEmpty)"
        }
    }
    
    /// title and url will always be nil for `Comment`.
    public var title: String? = nil
    public var url: String? = nil


    init(id: Int, parent: Int?, text: String?, by: String?, score: Int?, descendants: Int?, time: Int, kids: [Int]? = [Int](), level: Int? = 0) {
        self.id = id
        self.parent = parent
        self.title = String()
        self.text = text
        self.score = score
        self.by = by
        self.descendants = descendants
        self.time = time
        self.kids = kids
        self.level = level
    }

    // Empty initializer
    init() {
        self.init(id: 0, parent: 0, text: "", by: "", score: 0, descendants: 0, time: 0)
    }

    public func copyWith(text: String? = nil, level: Int? = nil) -> Comment {
        Comment(id: id, 
                parent: parent,
                text: text ?? self.text,
                by: by,
                score: score,
                descendants: descendants,
                time: time,
                kids: kids ?? [Int](),
                level: level ?? self.level)
    }
}

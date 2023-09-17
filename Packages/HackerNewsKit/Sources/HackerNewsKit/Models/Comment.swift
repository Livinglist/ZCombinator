public struct Comment: Item {
    public let id: Int
    public let parent: Int?
    public let title: String?
    public let text: String?
    public let url: String?
    public let type: String?
    public let by: String?
    public let score: Int?
    public let descendants: Int?
    public let time: Int
    public let kids: [Int]?
    public let level: Int?
    public var metadata: String? {
        if let count = kids?.count, count != 0 {
            return "\(count) cmt\(count > 1 ? "s":"") | \(timeAgo) by \(by.orEmpty)"
        } else {
            return "\(timeAgo) by \(by.orEmpty)"
        }
    }


    init(id: Int, parent: Int?, title: String? = nil, text: String?, url: String?, type: String?, by: String?, score: Int?, descendants: Int?, time: Int, kids: [Int] = [Int](), level: Int? = 0) {
        self.id = id
        self.parent = parent
        self.title = title
        self.text = text
        self.url = url
        self.type = type
        self.score = score
        self.by = by
        self.descendants = descendants
        self.time = time
        self.kids = kids
        self.level = level
    }

    // Empty initializer
    init() {
        self.init(id: 0, parent: 0, title: "", text: "", url: "", type: "", by: "", score: 0, descendants: 0, time: 0)
    }

    public func copyWith(text: String? = nil, level: Int? = nil) -> Comment {
        Comment(id: id, parent: parent, title: title, text: text ?? self.text, url: url, type: type, by: by, score: score, descendants: descendants, time: time, kids: kids ?? [Int](), level: level ?? self.level)
    }
}

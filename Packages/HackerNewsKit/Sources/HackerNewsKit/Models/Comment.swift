public struct Comment : Item {
    public let id: Int
    public let title: String?
    public let text: String?
    public let url: String?
    public let type: String?
    public let by: String?
    public let score: Int?
    public let descendants: Int?
    public let time: Int
    public let kids: [Int]?
    public var metadata: String? {
        "\(kids?.count ?? 0) cmts | \(timeAgo) by \(by.orEmpty)"
    }
    
    
    init(id: Int, title: String?, text: String?, url: String?, type: String?, by: String?, score: Int?, descendants: Int?, time: Int, kids: [Int] = [Int]()) {
        self.id = id
        self.title = title
        self.text = text
        self.url = url
        self.type = type
        self.score = score
        self.by = by
        self.descendants = descendants
        self.time = time
        self.kids = kids
    }
    
    // Empty initializer
    init() {
        self.init(id: 0, title: "", text: "", url: "", type: "", by: "", score: 0, descendants: 0, time: 0)
    }
    
    func copyWith(text: String?) -> Comment {
        Comment(id: id, title: title, text: text, url: url, type: type, by: by, score: score, descendants: descendants, time: time, kids: kids ?? [Int]())
    }
}

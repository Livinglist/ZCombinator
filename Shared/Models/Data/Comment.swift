import Foundation

struct Comment : Item {
    let id: Int
    let title: String?
    let text: String?
    let url: String?
    let type: String?
    let by: String?
    let score: Int?
    let descendants: Int?
    let time: Int
    let kids: [Int]?
    var metadata: String? {
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

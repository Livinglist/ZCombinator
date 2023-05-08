import Foundation

public struct User: Decodable, Equatable {
    public let id: String?
    public let about: String?
    public let created: Int?
    public let delay: Int?
    public let karma: Int?
    public let submitted: [Int]?
    
    public init() {
        self.id = String()
        self.about = String()
        self.created = Int()
        self.delay = Int()
        self.karma = Int()
        self.submitted = [Int]()
    }
    
    /// If a user does not have any activity, the user endpoint will not return anything.
    /// in that case, we create a user with only username.
    public init(id: String) {
        self.id = id
        self.about = String()
        self.created = Int()
        self.delay = Int()
        self.karma = Int()
        self.submitted = [Int]()
    }
    
    init(id: String?, about: String?, created: Int?, delay: Int?, karma: Int?, submitted: [Int]?) {
        self.id = id
        self.about = about
        self.created = created
        self.delay = delay
        self.karma = karma
        self.submitted = submitted
    }
    
    func copyWith(about: String? = nil) -> User {
        return User(id: id, about: about ?? self.about, created: created, delay: delay, karma: karma, submitted: submitted)
    }
}

public extension User {
    var createdAt: String? {
        guard let created = created else { return nil }
        let date = Date(timeIntervalSince1970: Double(created))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

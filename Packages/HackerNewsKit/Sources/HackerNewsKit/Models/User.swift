public struct User: Decodable {
    let id: String
    let about: String
    let created: Int
    let delay: Int
    let karma: Int
    
    init() {
        self.id = String()
        self.about = String()
        self.created = Int()
        self.delay = Int()
        self.karma = Int()
    }
    
    /// If a user does not have any activity, the user endpoint will not return anything.
    /// in that case, we create a user with only username.
    public init(id: String) {
        self.id = id
        self.about = String()
        self.created = Int()
        self.delay = Int()
        self.karma = Int()
    }
}

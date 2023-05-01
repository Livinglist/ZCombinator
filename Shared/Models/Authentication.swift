import Foundation

class Authentication: ObservableObject {
    @Published var username: String?
    @Published var loggedIn: Bool = false
    @Published var user: User?
    
    init(){
        Task {
            let loggedIn = AuthRepository.shared.loggedIn
            let username = AuthRepository.shared.username
            
            self.loggedIn = loggedIn
            self.username = username
            
            guard let username = username else { return }
            
            self.user = await AuthRepository.shared.fetchUser(username) ?? User(id: username)
        }
    }
    
    func logIn(username: String, password: String) async -> Bool {
        let loggedIn = await AuthRepository.shared.logIn(username: username, password: password)
        
        DispatchQueue.main.async {
            self.loggedIn = loggedIn
            
            if loggedIn {
                self.username = username
            }
        }
        
        return loggedIn
    }
    
    func logOut() {
        _ = AuthRepository.shared.logOut()
        self.loggedIn = false
        self.username = nil
    }
    
    func upvote(_ id: Int) async -> Bool {
        return await AuthRepository.shared.upvote(id)
    }
    
    func downvote(_ id: Int) async -> Bool {
        return await AuthRepository.shared.downvote(id)
    }
    
    func favorite(_ id: Int) async -> Bool {
        return await AuthRepository.shared.fav(id)
    }
    
    func reply(to id: Int, with text: String) async -> Bool {
        return await AuthRepository.shared.reply(to: id, with: text)
    }
}

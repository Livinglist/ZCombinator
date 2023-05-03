import Foundation
import Alamofire
import Security

public class AuthRepository {
    public static let shared: AuthRepository = AuthRepository()
    
    private let server: String = "news.ycombinator.com"
    private let baseUrl: String = "https://news.ycombinator.com"
    private let query: CFDictionary = [
        kSecClass: kSecClassInternetPassword,
        kSecAttrServer: "news.ycombinator.com",
        kSecReturnAttributes: true,
        kSecReturnData: true
    ] as CFDictionary
    
    private init() {}
    
    public var loggedIn: Bool {
        var result: AnyObject?
        _ = SecItemCopyMatching(query, &result)
        
        guard let dic = result as? NSDictionary else {
            return false
        }
        
        let username = dic[kSecAttrAccount] as! String?
        
        return username.isNotNullOrEmpty
    }
    
    public var username: String? {
        var result: AnyObject?
        _ = SecItemCopyMatching(query, &result)
        
        guard let dic = result as? NSDictionary else {
            return nil
        }
        
        let username = dic[kSecAttrAccount] as! String?
        
        return username
    }
    
    public var password: String? {
        var result: AnyObject?
        _ = SecItemCopyMatching(query, &result)
        
        guard let dic = result as? NSDictionary else {
            return nil
        }
        
        let passwordData = dic[kSecValueData] as! Data
        let password = String(data: passwordData, encoding: .utf8)
        
        return password
    }
    
    // MARK: - Authentication
    
    public func logIn(username: String, password: String, shouldRememberMe: Bool) async -> Bool {
        let parameters: [String: String] = [
            "acct": username,
            "pw": password
        ]
        let response = await AF.request("\(self.baseUrl)/login", method: .post, parameters: parameters, encoder: .urlEncodedForm).serializingString().response.response
        
        guard let url = response?.url else {
            return false
        }
        
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        let loggedIn = cookies.isNotNullOrEmpty
        
        if loggedIn && shouldRememberMe {
            let keychainItem = [
                kSecValueData: password.data(using: .utf8)!,
                kSecAttrAccount: username,
                kSecAttrServer: server,
                kSecClass: kSecClassInternetPassword,
                kSecReturnData: true,
                kSecReturnAttributes: true
            ] as CFDictionary
            
            var ref: AnyObject?
            
            _ = SecItemAdd(keychainItem, &ref)
        }
        
        return loggedIn
    }
    
    public func logOut() -> Bool {
        guard let url = URL(string: baseUrl) else {
            return false
        }
        
        guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
            return false
        }
        
        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        
        let query = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrServer: server,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
        
        
        let delStatus = SecItemDelete(query)
        
        if delStatus != 0 {
            return false
        }
        
        return true
    }
    
    public func fetchUser(_ id: String) async -> User? {
        let response = await AF.request("\(self.baseUrl)/user/\(id).json").serializingString().response
        
        if let data = response.data {
            let user = try? JSONDecoder().decode(User.self, from: data)
            
            return user
        } else {
            return nil
        }
    }
    
    // MARK: - Actions that require authentication
    
    public func flag(_ id: Int) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: [String: Any] = [
            "acct": username,
            "pw": password,
            "id": id,
        ]
        
        return await performPost(data: parameters, path: "/flag")
    }
    
    public func upvote(_ id: Int) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: Parameters = [
            "acct": username,
            "pw": password,
            "id": id,
            "how": "up",
        ]
    
        return await performPost(data: parameters, path: "/vote")
    }
    
    public func downvote(_ id: Int) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: [String: Any] = [
            "acct": username,
            "pw": password,
            "id": id,
            "how": "down",
        ]
        
        return await performPost(data: parameters, path: "/vote")
    }
    
    public func fav(_ id: Int) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: [String: Any] = [
            "acct": username,
            "pw": password,
            "id": id,
        ]
        
        return await performPost(data: parameters, path: "/fave")
    }
    
    public func unfav(_ id: Int) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: [String: Any] = [
            "acct": username,
            "pw": password,
            "id": id,
            "un": "t",
        ]
        
        return await performPost(data: parameters, path: "/fave")
    }
    
    public func reply(to id: Int, with text: String) async -> Bool {
        guard let username = self.username, let password = self.password else {
            return false
        }
        
        let parameters: [String: Any] = [
            "acct": username,
            "pw": password,
            "parent": id,
            "text": text,
        ]
        
        return await performPost(data: parameters, path: "/comment")
    }
    
    private func performPost(data: [String: Any], path: String) async -> Bool {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let request = AF.request("\(baseUrl)\(path)",
                                 method: .post,
                                 parameters: data,
                                 headers: HTTPHeaders([
                                    HTTPHeader(name: "content-type", value: "application/x-www-form-urlencoded")
                                 ]))
        let res = await request.serializingString().response
        guard let statusCode = res.response?.statusCode, statusCode == 200 else { return false }
        return true
    }
}

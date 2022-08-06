//
//  AuthRepository.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/5/22.
//

import Foundation
import Alamofire

class AuthRepository {
    static let shared: AuthRepository = AuthRepository()
    
    private let baseUrl: String = "https://news.ycombinator.com"
    
    func login(username: String, password: String) async -> Bool {
        let parameters: [String: String] = [
            "acct": "livinglist",
            "pw": "fjq11038"
        ]
        let response = await AF.request("\(self.baseUrl)/login", method: .post, parameters: parameters, encoder: .urlEncodedForm).serializingString().response.response
        
        print(response)
        
        guard let headerFields = response?.allHeaderFields as? [String: String], let url = response?.url else {
            return false
        }
        
        print(url)
        
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        
        print(cookies)
        
        return true
    }
}

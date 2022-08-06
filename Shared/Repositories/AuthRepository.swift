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
            "acct": username,
            "pw": password
        ]
        let response = await AF.request("\(self.baseUrl)/login", method: .post, parameters: parameters, encoder: .urlEncodedForm).serializingString().response.response
        
        guard let url = response?.url else {
            return false
        }
        
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        
        return cookies.isNotNullOrEmpty
    }
}

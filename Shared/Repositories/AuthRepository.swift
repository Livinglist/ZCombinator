//
//  AuthRepository.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/5/22.
//

import Foundation
import Alamofire
import Security

class AuthRepository {
    static let shared: AuthRepository = AuthRepository()
    
    private let server: String = "news.ycombinator.com"
    private let baseUrl: String = "https://news.ycombinator.com"
    
    var loggedIn: Bool {
        let query = [
          kSecClass: kSecClassInternetPassword,
          kSecAttrServer: server,
          kSecReturnAttributes: true,
          kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        print("Operation finished with status: \(status)")
        
        guard let dic = result as? NSDictionary else {
            return false
        }

        let username = dic[kSecAttrAccount] as! String?
        let passwordData = dic[kSecValueData] as! Data
        let password = String(data: passwordData, encoding: .utf8)!
        print("Username: \(username)")
        print("Password: \(password)")
        
        return !(username.valueOrEmpty.isEmpty)
    }
    
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
        let loggedIn = cookies.isNotNullOrEmpty
        
        if loggedIn {
            let keychainItem = [
              kSecValueData: username.data(using: .utf8)!,
              kSecAttrAccount: password,
              kSecAttrServer: server,
              kSecClass: kSecClassInternetPassword,
              kSecReturnData: true,
              kSecReturnAttributes: true
            ] as CFDictionary
            
            var ref: AnyObject?

            let status = SecItemAdd(keychainItem, &ref)
            let result = ref as! Data
            print("Operation finished with status: \(status)")
            let password = String(data: result, encoding: .utf8)!
            print("Password: \(password)")
        }
        
        return loggedIn
    }
    
    func logout() async -> Bool {
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
        print("Delete Operation finished with status: \(delStatus)")
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        print("Operation finished with status: \(status)")
        let dic = result as! NSDictionary

        let username = dic[kSecAttrAccount] ?? ""
        let passwordData = dic[kSecValueData] as! Data
        let password = String(data: passwordData, encoding: .utf8)!
        print("Username: \(username)")
        print("Password: \(password)")
        
        return true
    }
}

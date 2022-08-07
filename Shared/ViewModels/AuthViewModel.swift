//
//  AuthViewModel.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/6/22.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var username: String?
    @Published var loggedIn: Bool = false
    
    init(){
        Task {
            let loggedIn = AuthRepository.shared.loggedIn
            
            self.loggedIn = loggedIn
        }
    }
    
    func login(username: String, password: String) {
        Task {
            let loggedIn = await AuthRepository.shared.login(username: username, password: password)
            
            self.loggedIn = loggedIn
        }
    }
    
    func logout() {
        
    }
}

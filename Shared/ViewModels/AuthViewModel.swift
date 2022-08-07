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
            let username = AuthRepository.shared.username
            
            self.loggedIn = loggedIn
            self.username = username
        }
    }
    
    func logIn(username: String, password: String) {
        Task {
            let loggedIn = await AuthRepository.shared.logIn(username: username, password: password)
            
            DispatchQueue.main.async {
                self.loggedIn = loggedIn
                
                if loggedIn {
                    self.username = username
                }
            }
        }
    }
    
    func logOut() {
        _ = AuthRepository.shared.logOut()
        self.loggedIn = false
        self.username = nil
    }
    
    func upvote(_ id: Int) {
        Task {
            await AuthRepository.shared.upvote(id)
        }
    }
    
    func reply(to id: Int, with text: String) {
        Task {
            await AuthRepository.shared.reply(to: id, with: text)
        }
    }
}

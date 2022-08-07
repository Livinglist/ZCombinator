//
//  HomeViewToolbar.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/6/22.
//

import SwiftUI

extension HomeView {
    struct AuthButton: View {
        @EnvironmentObject private var authVm: AuthViewModel
        
        @Binding var showLoginDialog: Bool
        @Binding var showLogoutDialog: Bool
        
        var body: some View {
            if authVm.loggedIn {
                Button {
                    showLogoutDialog = true
                } label: {
                    Label(authVm.username.valueOrEmpty, systemImage: "person")
                }
            } else {
                Button {
                    showLoginDialog = true
                } label: {
                    Label("Log In", systemImage: "")
                }
            }
        }
    }
}

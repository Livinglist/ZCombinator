import SwiftUI

extension HomeView {
    struct AuthButton: View {
        @EnvironmentObject private var auth: Authentication
        
        @Binding var showLoginDialog: Bool
        @Binding var showLogoutDialog: Bool
        
        var body: some View {
            if auth.loggedIn {
                Button {
                    showLogoutDialog = true
                } label: {
                    Label(auth.username.orEmpty, systemImage: "person")
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

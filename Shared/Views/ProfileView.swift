import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: Authentication
    @StateObject var profileStore = ProfileStore()
    @State var showLogoutDialog = Bool()
    
    let id: String
    
    var body: some View {
        List {
            if let user = profileStore.user {
                Section {
                    Text(user.about.orEmpty.markdowned)
                } header: {
                    Text("About")
                }
                
                Section {
                    DetailedRow(title: "Created at", detail: user.createdAt.orEmpty)
                    DetailedRow(title: "Karma", detail: String(user.karma.orZero))
                    NavigationLink {
                        SubmissionView(ids: profileStore.user?.submitted ?? [Int]())
                    } label: {
                        Text("Submissions")
                    }
                } header: {
                    Text("Stats")
                }
                
                if auth.loggedIn && auth.username == id {
                    Button {
                        showLogoutDialog = true
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.forward")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("About \(id)")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .onAppear {
            if profileStore.status == .idle {
                Task {
                    await profileStore.fetchUser(id: id)
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutDialog, actions: {
            Button("Logout", role: .destructive, action: {
                HapticFeedbackService.shared.success()
                auth.logOut()
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Do you want to log out as \(auth.username.orEmpty)?")
        })
    }
}

extension ProfileView {
    struct DetailedRow: View {
        let title: String
        var detail: String? = nil
        
        var body: some View {
            HStack() {
                Text(title)
                if let detail = detail {
                    Spacer()
                    Text(detail).foregroundColor(Color(.secondaryLabel))
                }
            }
        }
    }
}

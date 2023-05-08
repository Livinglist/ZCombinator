import SwiftUI

struct ProfileView: View {
    @StateObject var profileStore = ProfileStore()
    let id: String
    
    var body: some View {
        List {
            if let user = profileStore.user {
                Section {
                    DetailedRow(title: "Created at", detail: user.createdAt.orEmpty)
                    DetailedRow(title: "Karma", detail: String(user.karma.orZero))
                } header: {
                    Text("Stats")
                }

                
                Section {
                    Text(user.about.orEmpty.markdowned)
                } header: {
                    Text("About")
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

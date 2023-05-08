import SwiftUI

extension ProfileView {
    class ProfileStore: ObservableObject {
        @Published user: User?
        
        func fetchUser(id: Int) async {
            
        }
    }
}

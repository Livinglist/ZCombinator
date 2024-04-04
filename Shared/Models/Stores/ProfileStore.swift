import SwiftUI
import HackerNewsKit

extension Profile {
    @MainActor
    class ProfileStore: ObservableObject {
        @Published var user: User?
        @Published var status: Status = .idle
        
        func fetchUser(id: String) async {
            self.status = .inProgress
            let user = await StoryRepository.shared.fetchUser(id)
            
            if let user = user {
                self.user = user
                self.status = .completed
            }
        }
    }
}

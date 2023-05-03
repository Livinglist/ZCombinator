import SwiftUI

struct UpvoteButton: View {
    @EnvironmentObject var auth: Authentication
    
    let id: Int
    var showUpvoteToast: Binding<Bool>
    
    var body: some View {
        Button {
            onUpvote()
        } label: {
            Label("Upvote", systemImage: "hand.thumbsup")
        }
        .disabled(!auth.loggedIn)
    }
    
    private func onUpvote() {
        Task {
            let res = await auth.upvote(id)
            
            if res {
                showUpvoteToast.wrappedValue = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

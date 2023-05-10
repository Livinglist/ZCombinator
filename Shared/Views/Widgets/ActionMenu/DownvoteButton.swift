import SwiftUI

struct DownvoteButton: View {
    @EnvironmentObject var auth: Authentication
    
    let id: Int
    let actionPerformed: Binding<Action>
    
    var body: some View {
        Button {
            onDownvote()
        } label: {
            Label("Downvote", systemImage: "hand.thumbsdown")
        }
        .disabled(!auth.loggedIn)
    }
    
    private func onDownvote() {
        Task {
            let res = await auth.downvote(id)
            
            if res {
                actionPerformed.wrappedValue = .downvote
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

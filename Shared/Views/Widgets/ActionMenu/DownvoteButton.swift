import SwiftUI

struct DownvoteButton: View {
    @EnvironmentObject var auth: Authentication
    
    let id: Int
    var showDownvoteToast: Binding<Bool>
    
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
                showDownvoteToast.wrappedValue = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

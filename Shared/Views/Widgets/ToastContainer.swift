import SwiftUI
import AlertToast

enum Action: Equatable {
    case flag
    case upvote
    case downvote
    case favorite
    case unfavorite
    case login
    case reply
    case none
    
    var systemImage: String {
        switch self {
        case .flag:
            return "flag.fill"
        case .upvote:
            return "hand.thumbsup.fill"
        case .downvote:
            return "hand.thumbsdown.fill"
        case .favorite:
            return "heart.fill"
        case .unfavorite:
            return "heart.slash"
        case .login:
            return "person.badge.shield.checkmark.fill"
        case .reply:
            return "arrowshape.turn.up.left.circle.fill"
        case .none:
            return String()
        }
    }
    
    var title: String {
        switch self {
        case .flag:
            return "Flagged"
        case .upvote:
            return "Upvoted"
        case .downvote:
            return "Downvoted"
        case .favorite:
            return "Added"
        case .unfavorite:
            return "Removed"
        case .login:
            return "Welcome"
        case .reply:
            return "Replied"
        case .none:
            return String()
        }
    }
}

struct ToastContainer<Content: View>: View {
    @State private var showToast = Bool()
    @Binding private var actionPerformed: Action

    let content: Content
    let withImage: Bool
    
    init(actionPerformed: Binding<Action>, withImage: Bool = true, @ViewBuilder _ contentBuilder: () -> Content) {
        self.content = contentBuilder()
        self.withImage = withImage
        self._actionPerformed = actionPerformed
    }
    
    var body: some View {
        content
            .toast(isPresenting: $showToast) {
                AlertToast(
                    type: withImage ? .systemImage(actionPerformed.systemImage, .gray) : .regular,
                    title: actionPerformed.title
                )
            }
            .onChange(of: actionPerformed) { val in
                if actionPerformed != .none {
                    showToast = true
                }
            }
    }
}

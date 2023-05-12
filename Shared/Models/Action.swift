/// Used for deciding which image or text to be shown in Toast alert.
enum Action: Equatable {
    case flag
    case upvote
    case downvote
    case favorite
    case unfavorite
    case pin
    case unpin
    case login
    case reply
    case copy
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
        case .pin:
            return "pin.fill"
        case .unpin:
            return "pin.slash"
        case .login:
            return "person.badge.shield.checkmark.fill"
        case .reply:
            return "arrowshape.turn.up.left.circle.fill"
        case .copy:
            return "doc.on.doc.fill"
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
        case .pin:
            return "Pinned"
        case .unpin:
            return "Unpinned"
        case .login:
            return "Welcome"
        case .reply:
            return "Replied"
        case .copy:
            return "Copied"
        case .none:
            return String()
        }
    }
}

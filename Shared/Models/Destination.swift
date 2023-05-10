import SwiftUI
import HackerNewsKit

enum Destination: Hashable {
    case pin
    case fav
    case search
    case submission([Int])
    case profile(String)
    case url(URL)
    case replyComment(Comment)
    case replyStory(Story)

    @ViewBuilder
    func toView() -> some View {
        switch self {
        case .pin:
            PinView()
        case .fav:
            FavView()
        case .search:
            SearchView()
        case let .submission(ids):
            SubmissionView(ids: ids)
        case let .profile(username):
            ProfileView(id: username)
        case let .url(url):
            WebView(url: url)
        case let .replyComment(cmt):
            ReplyView(replyingTo: cmt)
        case let .replyStory(story):
            ReplyView(replyingTo: story)
        }
    }
}

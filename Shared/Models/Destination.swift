import SwiftUI

enum Destination: Hashable {
    case pin
    case fav
    case search
    case submission([Int])
    case profile(String)

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
        }
    }
}

import SwiftUI
import AlertToast

struct FavView: View {
    @StateObject var favStore = FavStore()
    @State private var showFlagToast: Bool = Bool()
    @State private var showUpvoteToast: Bool = Bool()
    @State private var showDownvoteToast: Bool = Bool()
    @State private var showFavoriteToast: Bool = Bool()
    @State private var showUnfavoriteToast: Bool = Bool()
    private let settings = Settings.shared
    
    var body: some View {
        if settings.favList.isEmpty {
            Text("")
        }
        List {
            ForEach(favStore.items, id: \.self.id) { story in
                ItemRow(item: story,
                         showFlagToast: $showFlagToast,
                         showUpvoteToast: $showUpvoteToast,
                         showDownvoteToast: $showDownvoteToast,
                         showFavoriteToast: $showFavoriteToast,
                         showUnfavoriteToast: $showUnfavoriteToast)
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowSeparator(.hidden)
                .onAppear {
                    favStore.onItemRowAppear(story)
                }
            }
        }
        .navigationTitle(Text("Favorites"))
        .listStyle(.plain)
        .refreshable {
            Task {
                await favStore.refresh()
            }
        }
        .toast(isPresenting: $showFlagToast) {
            AlertToast(type: .systemImage("flag.fill", .gray), title: "Flagged")
        }
        .toast(isPresenting: $showUpvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsup.fill", .gray), title: "Upvoted")
        }
        .toast(isPresenting: $showDownvoteToast) {
            AlertToast(type: .systemImage("hand.thumbsdown.fill", .gray), title: "Downvoted")
        }
        .toast(isPresenting: $showUnfavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.slash", .gray), title: "Removed")
        })
        .toast(isPresenting: $showFavoriteToast, alert: {
            AlertToast(type: .systemImage("heart.fill", .gray), title: "Added")
        })
        .onAppear {
            if favStore.status == Status.idle {
                Task {
                    await favStore.fetchStories()
                }
            }
        }
    }
}

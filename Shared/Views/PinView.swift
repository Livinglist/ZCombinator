import AlertToast
import SwiftUI

struct PinView: View {
    @StateObject var pinStore = PinStore()
    @State private var showFlagToast = Bool()
    @State private var showUpvoteToast = Bool()
    @State private var showDownvoteToast = Bool()
    @State private var showLoginToast = Bool()
    @State private var showFavoriteToast = Bool()
    @State private var showUnfavoriteToast = Bool()
    
    var body: some View {        
        List {
            ForEach(pinStore.pinnedItems, id: \.self.id) { item in
                ItemRow(item: item,
                        isPinnedStory: true,
                        showFlagToast: $showFlagToast,
                        showUpvoteToast: $showUpvoteToast,
                        showDownvoteToast: $showDownvoteToast,
                        showFavoriteToast: $showFavoriteToast,
                        showUnfavoriteToast: $showUnfavoriteToast)
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .listRowSeparator(.hidden)
            }
        }
        .navigationTitle(Text("Pins"))
        .listStyle(.plain)
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
    }
}

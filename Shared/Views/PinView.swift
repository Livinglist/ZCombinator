import SwiftUI

struct PinView: View {
    @ObservedObject var pinStore = PinStore()
    @State private var showFlagToast: Bool = Bool()
    @State private var showUpvoteToast: Bool = Bool()
    @State private var showDownvoteToast: Bool = Bool()
    @State private var showLoginToast: Bool = Bool()
    @State private var showFavoriteToast: Bool = Bool()
    @State private var showUnfavoriteToast: Bool = Bool()
    
    var body: some View {
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
}

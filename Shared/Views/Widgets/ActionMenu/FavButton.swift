import SwiftUI

struct FavButton: View {
    @EnvironmentObject var auth: Authentication
    @ObservedObject private var settings = Settings.shared
    
    let id: Int
    var showUnfavoriteToast: Binding<Bool>
    var showFavoriteToast: Binding<Bool>
    
    var body: some View {
        Button {
            onFavorite()
        } label: {
            if settings.favList.contains(id) {
                Label("Unfavorite", systemImage: "heart.slash")
            } else {
                Label("Favorite", systemImage: "heart")
            }
        }
    }
    
    private func onFavorite() {
        let isFav = settings.favList.contains(id)
        if isFav {
            Task {
                _ = await auth.unfavorite(id)
                showUnfavoriteToast.wrappedValue = true
                HapticFeedbackService.shared.success()
            }
        } else {
            Task {
                _ = await auth.favorite(id)
                showFavoriteToast.wrappedValue = true
                HapticFeedbackService.shared.success()
            }
        }
        settings.onFavToggle(id)
    }
}

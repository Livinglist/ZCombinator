import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers
import HackerNewsKit

struct ItemRow: View {
    let settings = Settings.shared
    let item: any Item
    let url: URL?
    let isPinnedStory: Bool

    @EnvironmentObject var auth: Authentication

    @State private var showSafari: Bool = Bool()
    @State private var showHNSheet: Bool = Bool()
    @State private var showReplySheet: Bool = Bool()
    @State private var showFlagDialog: Bool = Bool()
    @GestureState private var isDetectingPress = Bool()
    @Binding private var showFlagToast: Bool
    @Binding private var showUpvoteToast: Bool
    @Binding private var showDownvoteToast: Bool
    @Binding private var showFavoriteToast: Bool
    @Binding private var showUnfavoriteToast: Bool

    init(item: any Item,
         isPinnedStory: Bool = false,
         showFlagToast: Binding<Bool>,
         showUpvoteToast: Binding<Bool>,
         showDownvoteToast: Binding<Bool>,
         showFavoriteToast: Binding<Bool>,
         showUnfavoriteToast: Binding<Bool>) {
        self.item = item
        self.url = URL(string: item.url ?? "https://news.ycombinator.com/item?id=\(item.id)")
        self.isPinnedStory = isPinnedStory
        self._showFlagToast = showFlagToast
        self._showUpvoteToast = showUpvoteToast
        self._showDownvoteToast = showDownvoteToast
        self._showFavoriteToast = showFavoriteToast
        self._showUnfavoriteToast = showUnfavoriteToast
    }

    @ViewBuilder
    var navigationLink: some View {
        if item is Story, item.isJobWithUrl {
            EmptyView()
        } else {
            NavigationLink(
                destination: {
                    ItemView(item: item)
                },
                label: {
                    EmptyView()
                })
        }
    }

    @ViewBuilder
    var menu: some View {
        Menu {
            UpvoteButton(id: item.id, showUpvoteToast: $showUpvoteToast)
            DownvoteButton(id: item.id, showDownvoteToast: $showDownvoteToast)
            FavButton(id: item.id, showUnfavoriteToast: $showUnfavoriteToast, showFavoriteToast: $showFavoriteToast)
            PinButton(id: item.id)
            Divider()
            FlagButton(id: item.id, showFlagDialog: $showFlagDialog)
            Divider()
            ShareMenu(item: item)
            Button {
                showHNSheet = true
            } label: {
                Label("View on Hacker News", systemImage: "safari")
            }
        } label: {
            Label("", systemImage: "ellipsis")
                .padding(.leading)
                .padding(.bottom, 12)
                .foregroundColor(.orange)
        }
    }

    var body: some View {
        ZStack {
            navigationLink
            Button(
                action: {
                    if item.isJobWithUrl {
                        showSafari = true
                    }
                },
                label: {
                    HStack {
                        VStack {
                            if item is Story {
                                Text(item.title.orEmpty)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .padding([.horizontal, .top])
                                Spacer()
                            }
                            HStack {
                                if let url = item.readableUrl {
                                    Text(url)
                                        .font(.footnote)
                                        .foregroundColor(.orange)
                                } else if let text = item.text {
                                    Text(text)
                                        .font(.footnote)
                                        .lineLimit(2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }.padding(item is Comment ? [.horizontal, .top] : [.horizontal])
                            Divider().frame(maxWidth: .infinity)
                            HStack(alignment: .center) {
                                Text(item.metadata.orEmpty)
                                    .font(.caption)
                                    .padding(.top, 6)
                                    .padding(.leading)
                                    .padding(.bottom, 12)
                                Spacer()
                                if isPinnedStory {
                                    Button {
                                        onPin()
                                    } label: {
                                        Label(String(), systemImage: "pin.fill")
                                            .rotationEffect(Angle(degrees: 45))
                                            .transformEffect(.init(translationX: 0, y: 5))
                                    }

                                } else {
                                    menu
                                }

                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
            )
            .if(.iOS16 && url != nil) { view in
                view
                    .contextMenu(
                    menuItems: {
                        Button {
                            showSafari = true
                        } label: {
                            Label("View in browser", systemImage: "safari")
                        }
                    },
                    preview: {
                        SafariView(url: url!)
                    })
            }
            .if(!.iOS16) { view in
                view
                    .contextMenu(
                    PreviewContextMenu(
                        destination: SafariView(url: url!),
                        actionProvider: { items in
                            return UIMenu(
                                title: "",
                                children: [
                                    UIAction(
                                        title: "View in browser",
                                        image: UIImage(systemName: "safari"),
                                        identifier: nil,
                                        handler: { _ in showSafari = true }
                                    )
                                ])
                        }))
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $showFlagDialog) {
            Button("Flag", role: .destructive) {
                onFlagTap()
            }
        } message: {
            Text("Flag \"\(item.title.orEmpty)\" by \(item.by.orEmpty)?")
        }
        .sheet(isPresented: $showHNSheet) {
            if let url = URL(string: item.itemUrl) {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showSafari) {
            if let urlStr = item.url, let url = URL(string: urlStr) {
                SafariView(url: url)
            }
        }
    }

    private func onUpvote() {
        Task {
            let res = await auth.upvote(item.id)

            if res {
                showUpvoteToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }

    private func onDownvote() {
        Task {
            let res = await auth.downvote(item.id)

            if res {
                showDownvoteToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }

    private func onFavorite() {
        let id = item.id
        let isFav = settings.favList.contains(id)
        if isFav {
            Task {
                _ = await auth.unfavorite(id)
                showUnfavoriteToast = true
                HapticFeedbackService.shared.success()
            }
        } else {
            Task {
                _ = await auth.favorite(id)
                showFavoriteToast = true
                HapticFeedbackService.shared.success()
            }
        }
        settings.onFavToggle(id)
    }
    
    private func onPin() {
        settings.onPinToggle(item.id)
        HapticFeedbackService.shared.light()
    }

    private func onFlagTap() {
        Task {
            let res = await AuthRepository.shared.flag(item.id)

            if res {
                showFlagToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

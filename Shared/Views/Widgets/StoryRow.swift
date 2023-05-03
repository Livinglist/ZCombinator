import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers

struct StoryRow: View {
    let story: Story
    let url: URL?
    let isPinnedStory: Bool

    @EnvironmentObject var auth: Authentication
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var isLoaded: Bool = Bool()
    @State private var showSafari: Bool = Bool()
    @State private var showHNSheet: Bool = Bool()
    @State private var showReplySheet: Bool = Bool()
    @State private var showFlagDialog: Bool = Bool()
    @GestureState private var isDetectingPress = Bool()
    @Binding private var showFlagToast: Bool
    @Binding private var showUpvoteToast: Bool
    @Binding private var showDownvoteToast: Bool
    @Binding private var showFavoriteToast: Bool

    init(story: Story,
         isPinnedStory: Bool = false,
         showFlagToast: Binding<Bool>,
         showUpvoteToast: Binding<Bool>,
         showDownvoteToast: Binding<Bool>,
         showFavoriteToast: Binding<Bool>) {
        self.story = story
        self.url = URL(string: story.url ?? "https://news.ycombinator.com/item?id=\(story.id)")
        self.isPinnedStory = isPinnedStory
        self._showFlagToast = showFlagToast
        self._showUpvoteToast = showUpvoteToast
        self._showDownvoteToast = showDownvoteToast
        self._showFavoriteToast = showFavoriteToast
    }

    @ViewBuilder
    var navigationLink: some View {
        if story.isJobWithUrl {
            EmptyView()
        } else {
            NavigationLink(
                destination: {
                    ItemView<Story>(item: story)
                },
                label: {
                    EmptyView()
                })
        }
    }

    @ViewBuilder
    var menu: some View {
        Menu {
            Button {
                onUpvote()
            } label: {
                Label("Upvote", systemImage: "hand.thumbsup")
            }
                .disabled(!auth.loggedIn)
            Button {
                onDownvote()
            } label: {
                Label("Downvote", systemImage: "hand.thumbsdown")
            }
                .disabled(!auth.loggedIn)
            Button {
                onFavorite()
            } label: {
                Label("Favorite", systemImage: "heart")
            }
                .disabled(!auth.loggedIn)

            Button {
                onPin()
            } label: {
                if isPinnedStory {
                    Label("Unpin", systemImage: "pin.slash.fill")
                } else {
                    Label("Pin", systemImage: "pin")
                }
            }
            Divider()
            Button {
                showFlagDialog = true
            } label: {
                Label("Flag", systemImage: "flag")
            }
                .disabled(!auth.loggedIn)
            Divider()
            Menu {
                if story.url.orEmpty.isNotEmpty {
                    Button {
                        showShareSheet(url: story.url.orEmpty)
                    } label: {
                        Text("Link to story")
                    }
                }
                Button {
                    showShareSheet(url: story.itemUrl)
                } label: {
                    Text("Link to HN")
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
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
                    if story.isJobWithUrl {
                        showSafari = true
                    }
                },
                label: {
                    HStack {
                        VStack {
                            Text(story.title.orEmpty)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding([.horizontal, .top])
                            Spacer()
                            HStack {
                                if let url = story.readableUrl {
                                    Text(url)
                                        .font(.footnote)
                                        .foregroundColor(.orange)
                                } else if let text = story.text {
                                    Text(text)
                                        .font(.footnote)
                                        .lineLimit(2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }.padding(.horizontal)
                            Divider().frame(maxWidth: .infinity)
                            HStack(alignment: .center) {
                                Text(story.metadata.orEmpty)
                                    .font(.caption)
                                    .padding(.top, 6)
                                    .padding(.leading)
                                    .padding(.bottom, 12)
                                Spacer()
                                if isPinnedStory {
                                    Button {
                                        settingsStore.onPinToggle(story.id)
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
                .if(.iOS16) { view in
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
            Text("Flag \"\(story.title.orEmpty)\" by \(story.by.orEmpty)?")
        }
            .sheet(isPresented: $showHNSheet) {
            if let url = URL(string: story.itemUrl) {
                SafariView(url: url)
            }
        }
            .sheet(isPresented: $showSafari) {
            if let urlStr = story.url, let url = URL(string: urlStr) {
                SafariView(url: url)
            }
        }

    }

    private func onUpvote() {
        Task {
            let res = await auth.upvote(story.id)

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
            let res = await auth.downvote(story.id)

            if res {
                showDownvoteToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }

    private func onFavorite() {
        Task {
            let res = await auth.favorite(story.id)

            if res {
                showFavoriteToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
    
    private func onPin() {
        settingsStore.onPinToggle(story.id)
        HapticFeedbackService.shared.light()
    }

    private func onFlagTap() {
        Task {
            let res = await AuthRepository.shared.flag(story.id)

            if res {
                showFlagToast = true
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

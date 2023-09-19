import SwiftUI
import WebKit
import HackerNewsKit

struct ItemView: View {
    @EnvironmentObject private var auth: Authentication
    @StateObject private var itemStore: ItemStore = .init()
    @State private var showHNSheet: Bool = .init()
    @State private var showUrlSheet: Bool = .init()
    @State private var showReplySheet: Bool = .init()
    @State private var showFlagDialog: Bool = .init()
    @State private var actionPerformed: Action = .none
    static private var handledUrl: URL? = nil
    static private var hnSheetTarget: (any Item)? = nil
    static private var replySheetTarget: (any Item)? = nil
    
    let settings: Settings = .shared
    
    let level: Int
    let item: any Item
    
    init(item: any Item, level: Int = 0) {
        self.level = level
        self.item = item
    }
    
    var body: some View {
        mainItemView
            .withToast(actionPerformed: $actionPerformed)
            .sheet(isPresented: $showHNSheet) {
                if let target = Self.hnSheetTarget, let url = URL(string: target.itemUrl) {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $showUrlSheet) {
                if let url = Self.handledUrl {
                    SafariView(url: url, draggable: true)
                }
            }
            .environment(\.openURL, OpenURLAction { url in
                if let id = url.absoluteString.itemId {
                    Task {
                        let item = await StoriesRepository.shared.fetchItem(id)
                        guard let item = item else {
                            Self.handledUrl = url
                            showUrlSheet = true
                            return
                        }
                        Router.shared.to(item)
                    }
                } else {
                    if showUrlSheet {
                        Router.shared.to(.url(url))
                    } else {
                        Self.handledUrl = url
                        showUrlSheet = true
                    }
                }
                return .handled
            })
            .sheet(isPresented: $showReplySheet) {
                if let target = Self.replySheetTarget {
                    ReplyView(actionPerformed: $actionPerformed,
                              replyingTo: target,
                              draggable: true
                    )
                }
            }
            .confirmationDialog("Are you sure?", isPresented: $showFlagDialog) {
                Button("Flag", role: .destructive) {
                    onFlagTap()
                }
            } message: {
                Text("Flag the post by \(item.by.orEmpty)?")
            }
            .onAppear {
                if itemStore.item == nil {
                    itemStore.item = item
                    Task {
                        await itemStore.refresh()
                    }
                }
            }
    }
    
    var menu: some View {
        Menu {
            Group {
                UpvoteButton(id: item.id, actionPerformed: $actionPerformed)
                DownvoteButton(id: item.id, actionPerformed: $actionPerformed)
                FavButton(id: item.id, actionPerformed: $actionPerformed)
                PinButton(id: item.id, actionPerformed: $actionPerformed)
            }
            Button {
                onReplyTap(item: item)
            } label: {
                Label("Reply", systemImage: "plus.message")
            }
            .disabled(!auth.loggedIn)
            Divider()
            FlagButton(id: item.id, showFlagDialog: $showFlagDialog)
            Divider()
            ShareMenu(item: item)
            if let text = item.text, text.isNotEmpty {
                CopyButton(text: text, actionPerformed: $actionPerformed)
            }
            Button {
                onViewOnHackerNewsTap(item: item)
            } label: {
                Label("View on Hacker News", systemImage: "safari")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.orange)
        }
    }
    
    @ViewBuilder
    var mainItemView: some View {
        ScrollView {
            nameRow
                .padding(.leading, 6)
                .padding(.trailing, 4)
                .padding(.top, 6)
            if item is Story {
                if let url = URL(string: item.url.orEmpty) {
                    ZStack {
                        LinkView(url: url, title: item.title.orEmpty)
                            .padding(.horizontal)
                            .allowsHitTesting(false)
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Self.handledUrl = url
                                showUrlSheet = true
                            }
                    }
                } else {
                    VStack(spacing: 0) {
                        Text(item.title.orEmpty)
                            .multilineTextAlignment(.center)
                            .fontWeight(.semibold)
                            .padding(.leading, 12)
                            .padding(.bottom, 4)
                        Text(item.text.orEmpty.markdowned)
                            .font(.callout)
                            .padding(.leading, 8)
                    }
                }
            } else if item is Comment {
                HStack {
                    Text(item.text.orEmpty.markdowned)
                        .font(.callout)
                        .padding(.leading, 8)
                    Spacer()
                }
            }
            if itemStore.status == .inProgress {
                LoadingIndicator().padding(.top, 100)
            }
            // In iOS 17, LazyVStack flitters whenever its contnet is updated.
            // Here we work around this by switching to VStack once all comments are fetched.
            if itemStore.status.isCompleted {
                VStack(spacing: 0) {
                    ForEach(itemStore.comments) { comment in
                        CommentTile(comment: comment, itemStore: itemStore, onShowHNSheet: {
                            onViewOnHackerNewsTap(item: comment)
                        }, onShowReplySheet: {
                            onReplyTap(item: comment)
                        }) {
                            Task {
                                await itemStore.loadKids(of: comment)
                            }
                        }
                        .padding(.trailing, 4)
                    }
                }
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(itemStore.comments) { comment in
                        CommentTile(comment: comment, itemStore: itemStore, onShowHNSheet: {
                            onViewOnHackerNewsTap(item: comment)
                        }, onShowReplySheet: {
                            onReplyTap(item: comment)
                        }) {
                            Task {
                                await itemStore.loadKids(of: comment)
                            }
                        }
                        .padding(.trailing, 4)
                    }
                }
            }
            Spacer().frame(height: 60)
            if itemStore.status == Status.completed {
                Text(Constants.happyFace)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
            }
        }
        .toolbar {
            if let item = item as? Comment {
                ToolbarItem {
                    Button {
                        Task {
                            await itemStore.fetchParent(of: item)
                        }
                    } label: {
                        Image(systemName: "backward.circle")
                    }
                }
            }
            ToolbarItem {
                menu
            }
        }
        .overlay {
            if itemStore.status.isLoading, let total = item.kids?.count, total != 0 {
                VStack {
                    ProgressView(value: Double(itemStore.comments.count), total: Double(total))
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            // Wrapped around in Task so that the default refresh indicator
            // doesn't wait for refresh() to complete.
            Task {
                await itemStore.refresh()
            }
        }
    }
    
    @ViewBuilder
    var nameRow: some View {
        let item = itemStore.item ?? item
        
        HStack {
            if let author = item.by {
                Button {
                    Router.shared.to(.profile(author))
                } label: {
                    Text(author)
                        .borderedFootnote()
                        .foregroundColor(getColor(level: level))
                }
            }
            
            if let karma = item.score {
                Text("\(karma) karma")
                    .borderedFootnote()
                    .foregroundColor(getColor())
            }
            if let descendants = item.descendants {
                Text("\(descendants) cmt\(descendants <= 1 ? "" : "s")")
                    .borderedFootnote()
                    .foregroundColor(getColor())
            }
            Spacer()
            Text(item.timeAgo)
                .borderedFootnote()
                .foregroundColor(getColor())
                .padding(.trailing, 2)
        }
    }
    
    private func onViewOnHackerNewsTap(item: any Item) {
        if showUrlSheet, let url = URL(string: item.itemUrl) {
            Router.shared.to(.url(url))
        } else {
            Self.hnSheetTarget = item
            showHNSheet = true
        }
    }
    
    private func onReplyTap(item: any Item) {
        if showUrlSheet {
            if let cmt = item as? Comment {
                Router.shared.to(.replyComment(cmt))
            } else if let story = item as? Story {
                Router.shared.to(.replyStory(story))
            }
        } else {
            Self.replySheetTarget = item
            showReplySheet = true
        }
    }

    private func onFlagTap() {
        Task {
            let res = await AuthRepository.shared.flag(item.id)

            if res {
                actionPerformed = .flag
                HapticFeedbackService.shared.success()
            } else {
                HapticFeedbackService.shared.error()
            }
        }
    }
}

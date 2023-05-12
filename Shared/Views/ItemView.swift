import SwiftUI
import WebKit
import HackerNewsKit

struct ItemView: View {
    @EnvironmentObject var auth: Authentication
    
    @StateObject var itemStore = ItemStore()
    @State private var isCollapsed = Bool()
    @State private var showHNSheet = Bool()
    @State private var showUrlSheet = Bool()
    @State private var showReplySheet = Bool()
    @State private var showFlagDialog = Bool()
    @State private var actionPerformed: Action = .none
    static private var handledUrl: URL? = nil
    static private var hnSheetTarget: (any Item)? = nil
    static private var replySheetTarget: (any Item)? = nil
    
    let level: Int
    let item: any Item
    let settings = Settings.shared
    
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
                    SafariView(url: url, dragDismissable: false)
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
                    ReplyView(actionPerformed: $actionPerformed, replyingTo: target)
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
            Label("", systemImage: "ellipsis")
                .foregroundColor(.orange)
        }
    }
    
    @ViewBuilder
    var mainItemView: some View {
        ScrollView {
            VStack(spacing: 0) {
                nameRow
                    .padding(.leading, 6)
                    .padding(.trailing, 4)
                if item is Story {
                    if let url = URL(string: item.url.orEmpty) {
                        ZStack {
                            LinkView(url: url, title: item.title.orEmpty)
                                .padding()
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
                                .padding(.top, 6)
                                .padding(.leading, 12)
                                .padding(.bottom, 6)
                            Text(item.text.orEmpty.markdowned)
                                .font(.callout)
                                .padding(.leading, 8)
                                .padding(.bottom, 6)
                        }
                    }
                } else if item is Comment {
                    VStack(spacing: 0) {
                        Text(item.text.orEmpty.markdowned)
                            .font(.callout)
                            .padding(.top, 6)
                            .padding(.leading, 8)
                            .padding(.bottom, 6)
                    }
                }
                if itemStore.status == .loading {
                    LoadingIndicator().padding(.top, 100)
                }
                VStack(spacing: 0) {
                    ForEach(itemStore.kids) { comment in
                        CommentTile(comment: comment, itemStore: itemStore, onShowHNSheet: {
                            onViewOnHackerNewsTap(item: comment)
                        }, onShowReplySheet: {
                            onReplyTap(item: comment)
                        }) {
                            Task {
                                await itemStore.loadKids(of: comment)
                            }
                        }.padding(.trailing, 4)
                    }
                }
                Spacer().frame(height: 60)
                if itemStore.status == Status.loaded {
                    Text(Constants.happyFace)
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
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
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await itemStore.refresh()
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
                Text("\(descendants) comment\(descendants <= 1 ? "" : "s")")
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

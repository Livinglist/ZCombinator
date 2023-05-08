import AlertToast
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
    @State private var showFlagToast = Bool()
    @State private var showUpvoteToast = Bool()
    @State private var showDownvoteToast = Bool()
    @State private var showReplyToast = Bool()
    @State private var showFavoriteToast = Bool()
    @State private var showUnfavoriteToast = Bool()
    private static var handledUrl: URL? = nil

    let level: Int
    let item: any Item
    let settings = Settings.shared

    init(item: any Item, level: Int = 0) {
        self.level = level
        self.item = item
    }

    var body: some View {
        mainItemView
            .sheet(isPresented: $showHNSheet) {
                if let url = URL(string: item.itemUrl) {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $showUrlSheet) {
                if let url = Self.handledUrl {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $showReplySheet) {
                ReplyView(showReplyToast: $showReplyToast, replyingTo: item)
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
            UpvoteButton(id: item.id, showUpvoteToast: $showUpvoteToast)
            DownvoteButton(id: item.id, showDownvoteToast: $showDownvoteToast)
            FavButton(id: item.id, showUnfavoriteToast: $showUnfavoriteToast, showFavoriteToast: $showFavoriteToast)
            PinButton(id: item.id)
            Button {
                showReplySheet = true
            } label: {
                Label("Reply", systemImage: "plus.message")
            }
            .disabled(!auth.loggedIn)
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
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    var textView: some View {
        if item is Story {
            Text(item.title.orEmpty)
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
        } else if item is Comment {
            if item.text.isNotNullOrEmpty {
                Text(item.text.orEmpty.markdowned)
                    .font(.system(size: 16))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            } else {
                Text("deleted")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 6)
            }
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
                                .font(.system(size: 16))
                                .padding(.leading, 8)
                                .padding(.bottom, 6)
                        }
                    }
                } else if item is Comment {
                    Text(item.text.orEmpty.markdowned)
                        .font(.system(size: 16))
                        .padding(.leading, 8)
                        .padding(.bottom, 6)
                }
                if itemStore.status == .loading {
                    LoadingIndicator().padding(.top, 100)
                }
                VStack(spacing: 0) {
                    ForEach(itemStore.kids) { comment in
                        CommentTile(comment: comment, itemStore: itemStore) {
                            Task {
                                await itemStore.loadKids(of: comment)
                            }
                        }.padding(.trailing, 4)
                    }.id(UUID())
                }
                Spacer().frame(height: 60)
                if itemStore.status == Status.loaded {
                    Text(Constants.happyFace)
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
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
        .toast(isPresenting: $showReplyToast) {
            AlertToast(type: .systemImage("arrowshape.turn.up.left.circle.fill", .gray), title: "Replied")
        }
        .toast(isPresenting: $showUnfavoriteToast, alert: {
                AlertToast(type: .systemImage("heart.slash", .gray), title: "Removed")
            })
        .toast(isPresenting: $showFavoriteToast) {
            AlertToast(type: .systemImage("heart.fill", .gray), title: "Added")
        }
        .toolbar {
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
            Text(item.by.orEmpty)
                .borderedFootnote()
                .foregroundColor(getColor())
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
    
    private func fetchStoryAndComments() {
        Task {
            await itemStore.refresh()
        }
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

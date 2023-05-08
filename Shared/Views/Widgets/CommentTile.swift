import AlertToast
import SwiftUI
import WebKit
import HackerNewsKit

extension ItemView {
    struct CommentTile: View {
        @EnvironmentObject var auth: Authentication
        @ObservedObject var itemStore: ItemStore
        
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
        let comment: Comment
        let settings = Settings.shared
        let onLoadMore: () -> Void
        
        init(comment: Comment, itemStore: ItemStore, onLoadMore: @escaping () -> Void) {
            self.level = comment.level ?? 0
            self.comment = comment
            self.onLoadMore = onLoadMore
            self.itemStore = itemStore
        }
        
        var body: some View {
            mainView
                .if(level > 0) { view -> AnyView in
                    var wrappedView = AnyView(view)
                    for i in (1...level).reversed() {
                        wrappedView = AnyView(
                            wrappedView
                            
                                .overlay(Rectangle().frame(width: 1, height: nil, alignment: .leading)
                                    .foregroundColor(getColor(level: i)), alignment: .leading)
                                .padding(.leading, 6)
                            
                        )
                    }
                    
                    return AnyView(wrappedView)
                }
                .sheet(isPresented: $showHNSheet) {
                    if let url = URL(string: comment.itemUrl) {
                        SafariView(url: url)
                    }
                }
                .sheet(isPresented: $showUrlSheet) {
                    if let url = Self.handledUrl {
                        SafariView(url: url)
                    }
                }
                .sheet(isPresented: $showReplySheet) {
                    ReplyView(showReplyToast: $showReplyToast, replyingTo: comment)
                }
                .confirmationDialog("Are you sure?", isPresented: $showFlagDialog) {
                    Button("Flag", role: .destructive) {
                        onFlagTap()
                    }
                } message: {
                    Text("Flag the post by \(comment.by.orEmpty)?")
                }
        }
        
        @ViewBuilder
        var menu: some View {
            Menu {
                UpvoteButton(id: comment.id, showUpvoteToast: $showUpvoteToast)
                DownvoteButton(id: comment.id, showDownvoteToast: $showDownvoteToast)
                FavButton(id: comment.id, showUnfavoriteToast: $showUnfavoriteToast, showFavoriteToast: $showFavoriteToast)
                PinButton(id: comment.id)
                Button {
                    showReplySheet = true
                } label: {
                    Label("Reply", systemImage: "plus.message")
                }
                .disabled(!auth.loggedIn)
                Divider()
                FlagButton(id: comment.id, showFlagDialog: $showFlagDialog)
                Divider()
                ShareMenu(item: comment)
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
            if comment.text.isNotNullOrEmpty {
                Text(comment.text.orEmpty.markdowned)
                    .font(.body)
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
        
        @ViewBuilder
        var mainView: some View {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    nameRow.padding(.bottom, 4)
                    if isCollapsed {
                        Button {
                            HapticFeedbackService.shared.ultralight()
                            withAnimation {
                                isCollapsed.toggle()
                            }
                        } label: {
                            Text("Collapsed")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(getColor(level: level))
                        }
                        
                    } else {
                        textView
                            .toast(isPresenting: $showFlagToast) {
                                AlertToast(type: .regular, title: "Flagged")
                            }
                            .toast(isPresenting: $showUpvoteToast) {
                                AlertToast(type: .regular, title: "Upvoted")
                            }
                            .toast(isPresenting: $showDownvoteToast) {
                                AlertToast(type: .regular, title: "Downvoted")
                            }
                            .toast(isPresenting: $showReplyToast) {
                                AlertToast(type: .regular, title: "Replied")
                            }
                            .toast(isPresenting: $showFavoriteToast) {
                                AlertToast(type: .regular, title: "Added")
                            }
                    }
                    if itemStore.loadingItem == comment.id {
                        LoadingIndicator().padding(.top, 16).padding(.bottom, 8)
                    } else if itemStore.loadedItems.contains(comment.id) == false && isCollapsed == false && comment.kids.isNotNullOrEmpty {
                        Button {
                            HapticFeedbackService.shared.light()
                            
                            onLoadMore()
                        } label: {
                            Text("Load \(comment.kids.countOrZero) \(comment.kids.isMoreThanOne ? "replies" : "reply")")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(getColor(level: level))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .padding(.top, 6)
                    }
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                .background(Color(UIColor.systemBackground))
                .contextMenu {
                    UpvoteButton(id: comment.id, showUpvoteToast: $showUpvoteToast)
                    DownvoteButton(id: comment.id, showDownvoteToast: $showDownvoteToast)
                    FavButton(id: comment.id, showUnfavoriteToast: $showUnfavoriteToast, showFavoriteToast: $showFavoriteToast)
                    PinButton(id: comment.id)
                    Button {
                        showReplySheet = true
                    } label: {
                        Label("Reply", systemImage: "plus.message")
                    }
                    .disabled(!auth.loggedIn)
                    Divider()
                    FlagButton(id: comment.id, showFlagDialog: $showFlagDialog)
                    Divider()
                    ShareMenu(item: comment)
                    Button {
                        showHNSheet = true
                    } label: {
                        Label("View on Hacker News", systemImage: "safari")
                    }
                }
                .onTapGesture {
                    HapticFeedbackService.shared.ultralight()
                    withAnimation {
                        isCollapsed.toggle()
                    }
                }
                Spacer()
            }
            .frame(alignment: .leading)
            .padding(.leading, 6)
        }
        
        @ViewBuilder
        var nameRow: some View {
            HStack {
                if let author = comment.by {
                    Button {
                        Router.shared.to(.profile(author))
                    } label: {
                        Text(author)
                            .borderedFootnote()
                            .foregroundColor(getColor(level: level))
                    }
                }

                if let karma = comment.score {
                    Text("\(karma) karma")
                        .borderedFootnote()
                        .foregroundColor(getColor(level: level))
                }
                if let descendants = comment.descendants {
                    Text("\(descendants) comment\(descendants <= 1 ? "" : "s")")
                        .borderedFootnote()
                        .foregroundColor(getColor(level: level))
                }
                Spacer()
                Text(comment.timeAgo)
                    .borderedFootnote()
                    .foregroundColor(getColor(level: level))
                    .padding(.trailing, 2)
            }
        }
        
        private func onFlagTap() {
            Task {
                let res = await AuthRepository.shared.flag(comment.id)
                
                if res {
                    showFlagToast = true
                    HapticFeedbackService.shared.success()
                } else {
                    HapticFeedbackService.shared.error()
                }
            }
        }
    }
}

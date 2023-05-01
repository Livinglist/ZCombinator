import AlertToast
import SwiftUI
import WebKit

struct ItemView<T : Item>: View {
    @EnvironmentObject var auth: Authentication
    
    @StateObject var itemStore: ItemStore<T> = ItemStore<T>()
    @State private var isCollapsed: Bool = false
    @State private var showHNSheet: Bool = false
    @State private var showReplySheet: Bool = false
    @State private var showFlagDialog: Bool = false
    @State private var showFlagToast: Bool = false
    @State private var showUpvoteToast: Bool = false
    @State private var showReplyToast: Bool = false
    
    let level: Int
    let item: T
    
    init(item: T, level: Int = 0) {
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
                if self.itemStore.item == nil {
                    self.itemStore.item = item
                }
            }
    }
    
    var menu: some View {
        Menu {
            Button {
                onUpvote()
            } label: {
                Label("Upvote", systemImage: "hand.thumbsup")
            }
            .disabled(!auth.loggedIn)
            Button {
                showReplySheet = true
            } label: {
                Label("Reply", systemImage: "plus.message")
            }
            .disabled(!auth.loggedIn)
            Divider()
            Button {
                showFlagDialog = true
            } label: {
                Label("Flag", systemImage: "flag")
            }
            .disabled(!auth.loggedIn)
            Divider()
            if item is Story {
                Menu {
                    if item.url.orEmpty.isNotEmpty {
                        Button {
                            showShareSheet(url: item.url.orEmpty)
                        } label: {
                            Text("Link to story")
                        }
                    }
                    Button {
                        showShareSheet(url: item.itemUrl)
                    } label: {
                        Text("Link to HN")
                    }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } else {
                Button {
                    showShareSheet(url: item.itemUrl)
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
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
    var rootView: some View {
        ScrollView {
            VStack(spacing: 0) {
                nameRow
                    .padding(.leading, 6)
                    .padding(.trailing, 4)
                if item is Story {
                    if let url = URL(string: item.url.orEmpty) {
                        LinkView(url: url, title: item.title.orEmpty)
                            .padding()
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
                    Text(item.text.orEmpty)
                        .padding(.leading, Double(4 * (level - 1)))
                }
                if itemStore.status == .loading {
                    LoadingIndicator().padding(.top, 100)
                } else if itemStore.status == .loaded && itemStore.kids.isEmpty {
                    Text("nothing yet")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                }
                VStack(spacing: 0) {
                    ForEach(itemStore.kids) { comment in
                        ItemView<Comment>(item: comment, level: level + 1)
                            .padding(.trailing, 4)
                    }.id(UUID())
                }
                Spacer().frame(height: 60)
            }
        }
        .toast(isPresenting: $showFlagToast) {
            AlertToast(type: .regular, title: "Flagged")
        }
        .toast(isPresenting: $showUpvoteToast) {
            AlertToast(type: .regular, title: "Upvoted")
        }
        .toast(isPresenting: $showReplyToast) {
            AlertToast(type: .regular, title: "Replied")
        }
        .toolbar {
            ToolbarItem{
                menu
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            itemStore.refresh()
        }
    }
    
    @ViewBuilder
    var nodeView: some View {
        ZStack {
            if level > 1 {
                HStack {
                    getColor(level: level)
                        .frame(width: 1)
                    Spacer()
                }
            }
            VStack(spacing: 0) {
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
                        textView.padding(.bottom, 3)
                            .toast(isPresenting: $showFlagToast) {
                                AlertToast(type: .regular, title: "Flagged")
                            }
                            .toast(isPresenting: $showUpvoteToast) {
                                AlertToast(type: .regular, title: "Upvoted")
                            }
                            .toast(isPresenting: $showReplyToast) {
                                AlertToast(type: .regular, title: "Replied")
                            }
                    }
                    if itemStore.status == Status.loading {
                        LoadingIndicator(color: getColor(level: level))
                            .padding(.top, 14)
                            .padding(.bottom, 10)
                    } else if isCollapsed == false && itemStore.status != Status.loaded && item.kids.isNotNullOrEmpty {
                        Button {
                            HapticFeedbackService.shared.light()
                            Task {
                                await itemStore.loadKids()
                            }
                        } label: {
                            Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")")
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
                    Button {
                        onUpvote()
                    } label: {
                        Label("Upvote", systemImage: "hand.thumbsup")
                    }
                    .disabled(!auth.loggedIn)
                    Button {
                        showReplySheet = true
                    } label: {
                        Label("Reply", systemImage: "plus.message")
                    }
                    .disabled(!auth.loggedIn)
                    Divider()
                    Button {
                        showFlagDialog = true
                    } label: {
                        Label("Flag", systemImage: "flag")
                    }
                    .disabled(!auth.loggedIn)
                    Divider()
                    Button {
                        showShareSheet(url: item.itemUrl)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
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
                if isCollapsed == false {
                    VStack(spacing: 0) {
                        ForEach(itemStore.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1)
                        }
                        .id(UUID())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .frame(alignment: .leading)
            .padding(.leading, 6)
        }
        .frame(maxWidth:.infinity)
        .frame(alignment: .leading)
    }
    
    @ViewBuilder
    var mainItemView: some View {
        if level == 0 {
            rootView
        } else {
            nodeView
        }
    }
    
    @ViewBuilder
    var nameRow: some View {
        HStack {
            Text(item.by.orEmpty)
                .borderedFootnote()
                .foregroundColor(getColor(level: level))
            if let karma = item.score {
                Text("\(karma) karma")
                    .borderedFootnote()
                    .foregroundColor(getColor(level: level))
            }
            if let descendants = item.descendants {
                Text("\(descendants) comments")
                    .borderedFootnote()
                    .foregroundColor(getColor(level: level))
            }
            Spacer()
            Text(item.timeAgo)
                .borderedFootnote()
                .foregroundColor(getColor(level: level))
                .padding(.trailing, 2)
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
    
    private func getColor(level: Int) -> Color {
        var level = level
        let initialLevel = level
        
        if let color = colors[initialLevel] {
            return color
        }
        
        while level >= 10 {
            level = level - 10
        }
        
        let r = 255
        var g = level * 40 < 255 ? 152 : (level * 20).clamped(to: 0...255)
        var b = (level * 40).clamped(to: 0...255)
        
        if (g == 255 && b == 255) {
            g = (level * 30 - 255).clamped(to: 0...255)
            b = (level * 40 - 255).clamped(to: 0...255)
        }
        
        let color = Color.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
        
        colors[initialLevel] = color
        
        return color
    }
}

var colors = [Int: Color]()

struct ItemVew_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

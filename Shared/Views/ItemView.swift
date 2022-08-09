//
//  ItemVew.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI
import WebKit

struct ItemView<T : ItemProtocol>: View {
    @EnvironmentObject var authVm: AuthViewModel
    @StateObject var vm: ItemViewModel<T> = ItemViewModel<T>()
    @State var showHNSheet: Bool = false
    @State var showReplySheet: Bool = false
    let level: Int
    let item: T
    
    init(item: T, level: Int = 0){
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
                ReplyView(replyingTo: item)
            }
            .onAppear {
                if self.vm.item == nil {
                    self.vm.item = item
                }
            }
    }
    
    var menu: some View {
        Menu {
            Button {
                
            } label: {
                Label("Upvote", systemImage: "hand.thumbsup")
            }
            .disabled(!authVm.loggedIn)
            Button {
                showReplySheet = true
            } label: {
                Label("Reply", systemImage: "plus.message")
            }
            .disabled(!authVm.loggedIn)
            Divider()
            Button {
                
            } label: {
                Label("Flag", systemImage: "flag")
            }
            Divider()
            Button {
                displayActionSheet()
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
        }
    }
    
    @ViewBuilder
    var textView: some View {
        if item is Story {
            Text("\(item.title.valueOrEmpty)")
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
        } else if item is Comment {
            if item.text.isNotNullOrEmpty {
                Text(item.text.valueOrEmpty.markdowned)
                    .font(.system(size: 16))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            } else {
                Text("deleted").font(.footnote).foregroundColor(.gray)
            }
        }
    }
    
    @ViewBuilder
    var mainItemView: some View {
        if level == 0 {
            ScrollView{
                VStack(spacing: 0) {
                    nameRow.padding(.leading, 6)
                    if item is Story {
                        if let url = URL(string: item.url.valueOrEmpty) {
                            LinkView(url: url, title: item.title.valueOrEmpty)
                                .padding()
                        } else {
                            VStack(spacing: 0) {
                                Text("\(item.title.valueOrEmpty)")
                                    .fontWeight(.semibold)
                                    .padding(.top, 6)
                                    .padding(.leading, 12)
                                    .padding(.bottom, 6)
                                Text("\(item.text.valueOrEmpty.markdowned)")
                                    .font(.system(size: 16))
                                    .padding(.leading, 4)
                                    .padding(.bottom, 6)
                            }
                        }
                    } else if item is Comment {
                        Text("\(item.text.valueOrEmpty)")
                            .padding(.leading, Double(4 * (level - 1)))
                    }
                    if vm.status == .loading {
                        LoadingIndicator().padding(.top, 12)
                    }
                    VStack(spacing: 0) {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1 )
                                .padding(.trailing, 4)
                        }.id(UUID())
                    }
                    Spacer().frame(height: 60)
                }
            }
            .toolbar {
                ToolbarItem{
                    menu
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        } else {
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
                        textView.padding(.bottom, 3)
                        if vm.status == Status.loading {
                            LoadingIndicator(color: getColor(level: level)).padding(.top, 12)
                        } else if vm.status != Status.loaded && item.kids.isNotNullOrEmpty {
                            Button {
                                let generator = UIImpactFeedbackGenerator()
                                generator.impactOccurred(intensity: 0.6)
                                Task {
                                    await vm.loadKids()
                                }
                            } label: {
                                Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")")
                                    .font(.footnote.weight(.bold))
                                    .foregroundColor(getColor(level: level))
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 6)
                        }
                    }
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                    .background(Color(UIColor.systemBackground))
                    .contextMenu {
                        Button {
                            
                        } label: {
                            Label("Upvote", systemImage: "hand.thumbsup")
                        }
                        .disabled(!authVm.loggedIn)
                        Button {
                            showReplySheet = true
                        } label: {
                            Label("Reply", systemImage: "plus.message")
                        }
                        .disabled(!authVm.loggedIn)
                        Divider()
                        Button {
                            
                        } label: {
                            Label("Flag", systemImage: "flag")
                        }
                        .disabled(!authVm.loggedIn)
                        Divider()
                        Button {
                            displayActionSheet()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button {
                            showHNSheet = true
                        } label: {
                            Label("View on Hacker News", systemImage: "safari")
                        }
                    }
                    VStack(spacing: 0) {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1)
                        }
                        .id(UUID())
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .frame(alignment: .leading)
                .padding(.leading, 6)
            }
            .frame(maxWidth:.infinity)
            .frame(alignment: .leading)
        }
    }
    
    @ViewBuilder
    var nameRow: some View {
        HStack {
            Text(item.by.valueOrEmpty)
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
            Text(item.timeAgo)
                .borderedFootnote()
                .foregroundColor(getColor(level: level))
            Spacer()
        }
    }
    
    
    func displayActionSheet() {
        guard let urlShare = URL(string: item.itemUrl) else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        
        // Get a scene that's showing (iPad can have many instances of the same app, some in the background)
        let activeScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
                
        let rootViewController = (activeScene?.windows ?? []).first(where: { $0.isKeyWindow })?.rootViewController
                
        // iPad stuff (fine to leave this in for all iOS devices, it will be effectively ignored when not needed)
        activityVC.popoverPresentationController?.sourceView = rootViewController?.view
        activityVC.popoverPresentationController?.sourceRect = .zero
        
        UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    func getColor(level: Int) -> Color {
        var level = level
        let initialLevel = level
        
        if colors[initialLevel] != nil {
            return colors[initialLevel]!
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
        //ItemView(item: Story())
        EmptyView()
    }
}

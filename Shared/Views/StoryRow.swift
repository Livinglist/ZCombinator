//
//  StoryView.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct StoryRow: View {
    let story: Story
    let url: URL?
    
    @State private var isLoaded: Bool = Bool()
    @State var showSafari = false
    @GestureState private var isDetectingPress = false
    
    init(story: Story){
        self.story = story
        self.url = URL(string: story.url ?? "https://news.ycombinator.com/item?id=\(story.id)")
    }
    
    var body: some View {
        VStack{
            if url == nil {
                Text(story.title ?? "")
            } else {
                ZStack {
                    NavigationLink(destination: {
                        ItemView<Story>(item: story)
                    }, label: {
                        EmptyView()
                    })
                    .sheet(isPresented: $showSafari) {
                        SafariView(url:url!)
                    }
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            VStack {
                                Text(story.title ?? "title").frame(maxWidth: .infinity, alignment: .leading).multilineTextAlignment(.leading)
                                Spacer()
                                HStack{
                                    if let url = story.readableUrl {
                                        Text(url).font(.footnote).foregroundColor(.orange)
                                    } else if let text = story.text {
                                        Text(text).font(.footnote).lineLimit(2).foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                Spacer()
                                HStack{
                                    Text("\(story.score ?? 0) pts | \(story.descendants ?? 0) cmts | \(story.createdAt) by \(story.by)").font(.caption)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                    })
                    .contextMenu(PreviewContextMenu(destination: SafariView(url:url!), actionProvider: { items in
                        return UIMenu(title: "My Menu", children: [UIAction(
                            title: "View in browser",
                            image: UIImage(systemName: "safari"),
                            identifier: nil,
                            handler: { _ in showSafari = true }
                        )])
                    }))
                }
            }
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(story: Story())
    }
}

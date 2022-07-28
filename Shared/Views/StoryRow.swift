//
//  StoryView.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct LinkView: UIViewRepresentable {
    typealias UIViewType = LPLinkView
    
    var url: URL
    let storyTitle: String
    
    func makeUIView(context: UIViewRepresentableContext<LinkView>) -> LinkView.UIViewType {
        return LPLinkView(url: url)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                metadata.title = storyTitle
                
                DispatchQueue.main.async {
                    uiView.metadata = metadata
                    uiView.sizeToFit()
                }
            }
        }
    }
}

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
                Button(action: {
                    self.showSafari = true
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
                                Text("\(story.score ?? 0) points | \(story.createdAt) by \(story.by)").font(.caption)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                })
//                .contextMenu {
//                    Button {
//                        // Add this item to a list of favorites.
//                    } label: {
//                        Label("Add to Favorites", systemImage: "heart")
//                    }
//                    Button {
//                        // Open Maps and center it on this item.
//                    } label: {
//                        Label("Show in Maps", systemImage: "mappin")
//                    }
//                } preview: {
//                    Image("turtlerock") // Loads the image from an asset catalog.
//                }
                .buttonStyle(ScaleButtonStyle())
                .sheet(isPresented: $showSafari) {
                    SafariView(url:url!)
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1).animation(.spring(), value: configuration.isPressed)
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(story: Story())
    }
}

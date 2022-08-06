//
//  LinkView.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/27/22.
//

import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct LinkView: UIViewRepresentable {
    typealias UIViewType = LPLinkView
    
    var url: URL
    let title: String
    
    func makeUIView(context: UIViewRepresentableContext<LinkView>) -> LinkView.UIViewType {
        return LPLinkView(url: url)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    metadata.title = title
                    uiView.metadata = metadata
                    uiView.sizeToFit()
                }
            } else {
                DispatchQueue.main.async {
                    let metadata = LPLinkMetadata()
                    metadata.title = title
                    metadata.url = url
                    uiView.metadata = metadata
                    uiView.sizeToFit()
                }
            }
        }
    }
}

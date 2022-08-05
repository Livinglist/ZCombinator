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
    
    func makeUIView(context: UIViewRepresentableContext<LinkView>) -> LinkView.UIViewType {
        return LPLinkView(url: url)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    uiView.metadata = metadata
                    uiView.sizeToFit()
                }
            }
        }
    }
}

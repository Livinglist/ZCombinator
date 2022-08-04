//
//  CustomText.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/4/22.
//

import Foundation
import SwiftUI

struct CustomText: UIViewRepresentable {
    let html: String
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            let data = Data(self.html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                uiView.isEditable = false
                uiView.attributedText = attributedString
            }
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let label = UITextView()
        return label
    }
}

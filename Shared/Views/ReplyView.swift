//
//  ReplyView.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 8/6/22.
//

import SwiftUI

struct ReplyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var text: String = ""
    
    let replyingTo: any ItemProtocol
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel", role: .cancel) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding()
                Spacer()
                Button("Submit") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(text.isEmpty)
                .padding()
            }
            HStack {
                Text("Replying \(replyingTo.by.valueOrEmpty)")
                    .font(.footnote)
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
                Spacer()
            }
            TextField("", text: $text,  axis: .vertical)
                .lineLimit(10...100)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)
            Spacer()
        }
    }
}

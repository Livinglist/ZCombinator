import SwiftUI

struct ReplyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var text: String = ""
    
    let replyingTo: any Item
    
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
                Text("Replying \(replyingTo.by.orEmpty)")
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

import SwiftUI

struct ReplyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var text: String = ""
    @FocusState private var focusState: Bool
    
    @Binding var showReplyToast: Bool
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
                    showReplyToast = true
                    HapticFeedbackService.shared.success()
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(text.isEmpty)
                .padding()
            }
            HStack {
                Text("Replying to \(replyingTo.by.orEmpty)")
                    .font(.footnote)
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
                Spacer()
            }
            TextField("", text: $text,  axis: .vertical)
                .lineLimit(10...100)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)
                .focused($focusState)
            Spacer()
        }
    }
}

import SwiftUI
import HackerNewsKit

struct ReplyView: View {
    @EnvironmentObject var auth: Authentication
    @Environment(\.presentationMode) var presentationMode
    
    @State private var text: String = String()
    @FocusState private var focusState: Bool
    
    @Binding var actionPerformed: Action
    let replyingTo: any Item
    
    init(actionPerformed: Binding<Action>, replyingTo: any Item) {
        self._actionPerformed = actionPerformed
        self.replyingTo = replyingTo
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel", role: .cancel) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding()
                Spacer()
                Button("Submit") {
                    Task {
                        let res = await auth.reply(to: replyingTo.id, with: text)
                        
                        if res {
                            actionPerformed = .reply
                            HapticFeedbackService.shared.success()
                        } else {
                            HapticFeedbackService.shared.error()
                        }
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
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

import SwiftUI

struct CopyButton: View {
    let text: String
    let actionPerformed: Binding<Action>
    
    var body: some View {
        Button {
            onCopy()
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
    }
    
    private func onCopy() {
        UIPasteboard.general.string = text
        actionPerformed.wrappedValue = .copy
        HapticFeedbackService.shared.success()
    }
}

import SwiftUI
import AlertToast

struct ToastContainer<Content: View>: View {
    @State private var showToast: Bool = .init()
    @Binding private var actionPerformed: Action

    let content: Content
    let withImage: Bool
    
    init(actionPerformed: Binding<Action>, withImage: Bool = true, @ViewBuilder _ contentBuilder: () -> Content) {
        self.content = contentBuilder()
        self.withImage = withImage
        self._actionPerformed = actionPerformed
    }
    
    var body: some View {
        content
            .toast(isPresenting: $showToast) {
                AlertToast(
                    type: withImage ? .systemImage(actionPerformed.systemImage, .gray) : .regular,
                    title: actionPerformed.title
                )
            }
            .onChange(of: actionPerformed) { val in
                if val != .none {
                    showToast = true
                }
            }.onChange(of: showToast) { val in
                // Reset action after displaying the toast.
                if !val {
                    actionPerformed = .none
                }
            }
    }
}

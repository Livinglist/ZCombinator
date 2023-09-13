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
            .onChange(of: actionPerformed) { _, newValue in
                if newValue != .none {
                    showToast = true
                }
            }
            .onChange(of: showToast) { _, newValue in
                // Reset action after displaying the toast.
                if !newValue {
                    actionPerformed = .none
                }
            }
    }
}

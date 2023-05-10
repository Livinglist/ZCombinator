import SwiftUI
import SafariServices

struct SafariView: View {
    @State var presentationDetent: PresentationDetent = .large
    
    let url: URL
    let dragDismissable: Bool
    
    init(url: URL, dragDismissable: Bool = true) {
        self.url = url
        self.dragDismissable = dragDismissable
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            SafariBaseView(url: url)
            // Workaround for increasing the size of draggable area.
            Color
                .white.opacity(0.001)
                .frame(width: 150, height: 50)
        }
        .ignoresSafeArea(.all)
        .if(!dragDismissable) { view in
            view
                .presentationDetents([.height(100), .large], selection: $presentationDetent)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
    }
}

extension SafariView {
    fileprivate struct SafariBaseView: UIViewControllerRepresentable {
        typealias UIViewControllerType = SFSafariViewController
        
        let url: URL
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariBaseView>) -> SFSafariViewController {
            let controller = SFSafariViewController(url: url)
            controller.preferredControlTintColor = .orange
            controller.dismissButtonStyle = .close
            return controller
        }
        
        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariBaseView>) {
        }
    }
}

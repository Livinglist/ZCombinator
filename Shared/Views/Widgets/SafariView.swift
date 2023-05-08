import SwiftUI
import SafariServices

struct SafariView: View {
    let url: URL
    
    var body: some View {
        SafariBaseView(url: url)
            .ignoresSafeArea(.all)
    }
}

private struct SafariBaseView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariBaseView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .orange
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariBaseView>) {
    }
}

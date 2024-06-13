import SwiftUI

struct Favicon: View {
    let url: String

    var body: some View {
        if let url = URL(string: url), 
           let host = url.host(),
           let faviconUrl = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=32") {
            AsyncImage(
                url: faviconUrl,
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 16, height: 16)
                }, placeholder: {
                    ProgressView()
                        .frame(width: 16, height: 16)
                }
            )
        } else {
            EmptyView()
        }
    }
}

#Preview {
    Favicon(url: "https://news.ycombinator.com")
}

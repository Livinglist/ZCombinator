import SwiftUI
import HackerNewsKit

@main
struct ZCombinatorApp: App {
    let auth = Authentication()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(auth)
                .onAppear {
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("ShareKey"), object: nil, queue: nil) { val in
                        print(val)
                        self.close()
                    }
                }
                .onOpenURL(perform: { url in
                    print("url is \(url)")
                    guard let id = Int(url.absoluteString) else { return }
                    Task {
                        let story = await StoriesRepository.shared.fetchStory(id)
                        guard let story = story else { return }
                    }
                })
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("ShareKey"), object: nil)
    }
}

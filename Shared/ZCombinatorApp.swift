import SwiftUI
import HackerNewsKit

@main
struct ZCombinatorApp: App {
    let auth = Authentication()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(auth)
        }
    }
}

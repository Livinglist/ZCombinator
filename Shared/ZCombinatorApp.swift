import SwiftUI

@main
struct ZCombinatorApp: App {
    let auth = Authentication()
    let settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(self.auth)
                .environmentObject(self.settingsStore)
        }
    }
}

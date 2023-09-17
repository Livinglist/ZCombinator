import BackgroundTasks
import Foundation
import SwiftUI
import SwiftData
import HackerNewsKit
import UserNotifications

@main
struct ZCombinatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    let auth: Authentication = .shared
    let notification: AppNotification = .shared
    let offlineRepository: OfflineRepository = .shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(auth)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                }
        }
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .background: notification.scheduleFetching()
            default: break
            }
        }
        .backgroundTask(.appRefresh(Constants.AppNotification.backgroundTaskId)) {
            await notification.fetchAllReplies()
        }
    }
}

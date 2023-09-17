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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task {
            let content = response.notification.request.content
            if let id = Int(content.targetContentIdentifier ?? ""),
               id != 0,
               let item = await StoriesRepository.shared.fetchComment(id) {
                Router.shared.to(item)
            }
        }
    }
}

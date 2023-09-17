import BackgroundTasks
import Foundation
import SwiftUI
import HackerNewsKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.Download.backgroundTaskId,
                                        using: nil) { task in
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            
            Task {
                await OfflineRepository.shared.downloadAllStories()
                
                task.setTaskCompleted(success: true)
            }
            
            self.scheduleBackgroundDownload()
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Register SceneDelegate.
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func scheduleBackgroundDownload() {
        let downloadTask = BGProcessingTaskRequest(identifier: Constants.Download.backgroundTaskId)
        // Set earliestBeginDate to be 6 hrs from now.
        downloadTask.earliestBeginDate = Date(timeIntervalSinceNow: 21600)
        downloadTask.requiresNetworkConnectivity = true
        downloadTask.requiresExternalPower = true
        do {
            try BGTaskScheduler.shared.submit(downloadTask)
        } catch {
            debugPrint("Unable to submit task: \(error.localizedDescription)")
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundDownload()
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

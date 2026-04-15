// FoodZippyApp.swift
// FoodZippy - iOS Customer App
// Converted from Android Java to Swift/SwiftUI

import SwiftUI
import UserNotifications
// import FirebaseCore
// TODO: Uncomment after adding Firebase via SPM

@main
struct FoodZippyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var sessionManager = SessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(cartManager)
                .environmentObject(sessionManager)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // FirebaseApp.configure()
        // TODO: Uncomment after adding Firebase via SPM
        
        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        SessionManager.shared.fcmToken = token
        
        // Sync token to server if logged in
        if SessionManager.shared.isLoggedIn {
            Task {
                try? await APIService.shared.saveToken(userId: SessionManager.shared.currentUser?.id ?? "", token: token)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: .didReceivePushNotification, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}

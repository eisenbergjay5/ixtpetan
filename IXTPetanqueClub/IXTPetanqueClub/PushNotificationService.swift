import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UIKit
import UserNotifications

extension Notification.Name {
    static let fcmTokenDidChange = Notification.Name("fcmTokenDidChange")
}

final class PushNotificationService: NSObject {
    static let shared = PushNotificationService()
    private let defaultTopics = ["club_de_lyon", "fr_petanque"]

    private override init() {
        super.init()
    }

    var fcmToken: String? {
        UserDefaults.standard.string(forKey: "fcmToken")
    }

    var isFirebaseConfigured: Bool {
        FirebaseApp.app() != nil
    }

    var isPushEnabled: Bool {
        UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
    }

    func configureFirebaseIfPossible() {
        guard FirebaseApp.app() == nil else { return }
        guard hasUsableGoogleServiceInfo else {
            print("Firebase is not configured: replace GoogleService-Info.plist with the file from Firebase Console.")
            return
        }

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Push authorization failed: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                guard granted else { return }
                UserDefaults.standard.set(true, forKey: "pushNotificationsEnabled")
                UIApplication.shared.registerForRemoteNotifications()
                self.refreshFCMToken()
            }
        }
    }

    func disablePushNotifications() {
        UserDefaults.standard.set(false, forKey: "pushNotificationsEnabled")
        UIApplication.shared.unregisterForRemoteNotifications()

        guard isFirebaseConfigured else { return }
        defaultTopics.forEach { topic in
            Messaging.messaging().unsubscribe(fromTopic: topic)
        }
        Messaging.messaging().deleteToken { error in
            if let error {
                print("FCM token deletion failed: \(error.localizedDescription)")
            }
            UserDefaults.standard.removeObject(forKey: "fcmToken")
            NotificationCenter.default.post(name: .fcmTokenDidChange, object: nil)
        }
    }

    func refreshFCMToken() {
        guard isFirebaseConfigured else { return }
        Messaging.messaging().token { token, error in
            if let error {
                print("FCM token refresh failed: \(error.localizedDescription)")
                return
            }
            self.storeFCMToken(token)
            self.subscribeToDefaultTopics()
        }
    }

    func updateAPNsToken(_ deviceToken: Data) {
        guard isFirebaseConfigured, isPushEnabled else { return }
        Messaging.messaging().apnsToken = deviceToken
        refreshFCMToken()
    }

    private var hasUsableGoogleServiceInfo: Bool {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path),
            let appID = plist["GOOGLE_APP_ID"] as? String,
            let bundleID = plist["BUNDLE_ID"] as? String
        else {
            return false
        }

        return !appID.contains("REPLACE") && bundleID == Bundle.main.bundleIdentifier
    }

    private func storeFCMToken(_ token: String?) {
        guard let token, !token.isEmpty else { return }
        UserDefaults.standard.set(token, forKey: "fcmToken")
        NotificationCenter.default.post(name: .fcmTokenDidChange, object: token)
    }

    private func subscribeToDefaultTopics() {
        guard isFirebaseConfigured, isPushEnabled else { return }
        defaultTopics.forEach { topic in
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error {
                    print("FCM topic subscription failed for \(topic): \(error.localizedDescription)")
                }
            }
        }
    }
}

extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        storeFCMToken(fcmToken)
        subscribeToDefaultTopics()
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        PushNotificationService.shared.configureFirebaseIfPossible()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationService.shared.updateAPNsToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

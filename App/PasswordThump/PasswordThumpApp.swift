import SwiftUI
import UIKit
import UserNotifications

@main
struct PasswordThumpApp: App {
    init() {
        AppBadgeManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}

enum AppBadgeManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { _, _ in }
    }

    static func setBadge(to value: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = value
        }
    }
}

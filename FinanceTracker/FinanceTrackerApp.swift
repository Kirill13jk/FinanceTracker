import SwiftUI
import SwiftData
import UserNotifications

@main
struct FinanceTrackerApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [Transaction.self, Budget.self, Category.self, Post.self, Goal.self])
    }
}

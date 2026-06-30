import BackgroundTasks
import SwiftUI

/// The main app entry point.
///
/// Configures the app window and registers background task identifiers.
@main
struct LinkMeApp: App {
    init() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.linkme.contact-sync",
            using: nil
        ) { task in
            Task { @MainActor in
                ContactSyncManager.shared.handleBackgroundProcessingTask(task as! BGProcessingTask)
            }
        }
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.linkme.contact-sync-refresh",
            using: nil
        ) { task in
            Task { @MainActor in
                ContactSyncManager.shared.handleBackgroundRefreshTask(task as! BGAppRefreshTask)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}

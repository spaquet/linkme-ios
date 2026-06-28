import Combine
import EventKit
import Foundation

/// Manages calendar access and event queries for briefings.
///
/// Fetches upcoming events to show in the "Up Next" section of Today view
/// and powers the "Brief me before 3pm" use case.
///
/// - Note: Requires full calendar access (iOS 17+) or event access (iOS 16 and below).
@MainActor
final class CalendarManager: ObservableObject {
    /// Shared singleton instance.
    static let shared = CalendarManager()

    /// Current authorization status for calendar access.
    @Published private(set) var authorizationStatus: EKAuthorizationStatus

    /// Whether calendar access is fully authorized.
    @Published private(set) var isEnabled: Bool

    private let eventStore = EKEventStore()
    private let enabledKey = "calendarAccessEnabled"

    private init() {
        let status = EKEventStore.authorizationStatus(for: .event)
        authorizationStatus = status
        isEnabled = status == .fullAccess
    }

    /// Whether full calendar access has been granted.
    var isFullAccessGranted: Bool {
        authorizationStatus == .fullAccess
    }

    /// Request full calendar access from the user.
    ///
    /// Shows the system permission dialog (iOS 17+) or legacy access request (iOS 16 and below).
    /// Automatically updates ``authorizationStatus`` and ``isEnabled`` after user responds.
    func requestAccess() {
        Task {
            do {
                if #available(iOS 17.0, *) {
                    _ = try await eventStore.requestFullAccessToEvents()
                } else {
                    let _: Bool = try await withCheckedThrowingContinuation { continuation in
                        eventStore.requestAccess(to: .event) { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: granted)
                            }
                        }
                    }
                }
            } catch {}

            updateStatus()
        }
    }

    /// Refresh the current calendar authorization status.
    ///
    /// Use after system settings changes or to sync state.
    func refreshStatus() {
        updateStatus()
    }

    private func updateStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        isEnabled = authorizationStatus == .fullAccess
    }
}

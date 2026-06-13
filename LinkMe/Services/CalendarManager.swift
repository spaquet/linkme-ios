import Combine
import EventKit
import Foundation

@MainActor
final class CalendarManager: ObservableObject {
    static let shared = CalendarManager()

    @Published private(set) var authorizationStatus: EKAuthorizationStatus
    @Published private(set) var isEnabled: Bool

    private let eventStore = EKEventStore()
    private let enabledKey = "calendarAccessEnabled"

    private init() {
        let status = EKEventStore.authorizationStatus(for: .event)
        authorizationStatus = status
        isEnabled = status == .fullAccess
    }

    var isFullAccessGranted: Bool {
        authorizationStatus == .fullAccess
    }

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

    func refreshStatus() {
        updateStatus()
    }

    private func updateStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        isEnabled = authorizationStatus == .fullAccess
    }
}

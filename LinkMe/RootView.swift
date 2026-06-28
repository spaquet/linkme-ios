import SwiftUI

/// Root view that routes between onboarding and main app.
///
/// Conditionally displays ``OnboardingView`` or ``MainTabView`` based on onboarding state.
struct RootView: View {
    /// App state (identity, onboarding flag).
    @State private var appState = AppState()

    /// Conditional view based on onboarding status.
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView(appState: appState)
            } else {
                OnboardingView(appState: appState, onDone: {
                    appState.hasCompletedOnboarding = true
                })
            }
        }
    }
}

#Preview {
    RootView()
}

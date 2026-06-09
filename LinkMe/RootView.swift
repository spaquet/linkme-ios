import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding && appState.currentUser != nil {
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

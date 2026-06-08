import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(onDone: {
                    appState.hasCompletedOnboarding = true
                })
            }
        }
    }
}

#Preview {
    RootView()
}

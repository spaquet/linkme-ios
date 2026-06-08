import SwiftUI

struct OnboardingScreen: View {
    var onDone: () -> Void

    var body: some View {
        VStack {
            Text("LinkMe")
                .font(.title)
            Text("Onboarding coming soon")
                .font(.subheadline)
            Button("Continue", action: onDone)
        }
    }
}

#Preview {
    OnboardingScreen(onDone: {})
}

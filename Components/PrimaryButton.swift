import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let tone: ButtonTone
    let fullWidth: Bool

    enum ButtonTone {
        case ink
        case teal
    }

    init(_ title: String, tone: ButtonTone = .ink, fullWidth: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.tone = tone
        self.fullWidth = fullWidth
        self.action = action
    }

    private var backgroundColor: Color {
        tone == .teal ? LinkMeColors.t500 : LinkMeColors.ink
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16.5, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: 54)
        }
        .background(backgroundColor)
        .cornerRadius(LinkMeLayout.cornerRadius)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton("Continue") {}
        PrimaryButton("Get Started", tone: .teal) {}
        PrimaryButton("Button", fullWidth: false) {}
    }
    .padding()
}

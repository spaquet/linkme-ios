import SwiftUI

/// A primary call-to-action button.
///
/// Full-width or fixed-width button with ink or teal tone. Respects enabled state.
struct PrimaryButton: View {
    /// Button title text.
    let title: String

    /// Callback when button is tapped.
    let action: () -> Void

    /// Button color tone.
    let tone: ButtonTone

    /// Whether button expands to full width (default true).
    let fullWidth: Bool

    /// Environment enabled state affects opacity.
    @Environment(\.isEnabled) private var isEnabled

    /// Button tone options.
    enum ButtonTone {
        /// Dark ink color.
        case ink
        /// Teal (primary action).
        case teal
    }

    /// Create a primary button.
    ///
    /// - Parameters:
    ///   - title: Button text.
    ///   - tone: Color tone (default ink).
    ///   - fullWidth: Expand to width (default true).
    ///   - action: Callback when tapped.
    init(_ title: String, tone: ButtonTone = .ink, fullWidth: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.tone = tone
        self.fullWidth = fullWidth
        self.action = action
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return tone == .teal ? LinkMeColors.t500 : LinkMeColors.ink
        }
        return tone == .teal ? LinkMeColors.t500 : LinkMeColors.ink
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
        .opacity(isEnabled ? 1.0 : 0.5)
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

import SwiftUI

/// A container card with rounded corners, white background, and shadow.
///
/// Generic view that wraps content in a white surface with subtle shadow.
/// Uses design system colors and spacing.
struct Card<Content: View>: View {
    /// Content view builder closure result.
    let content: Content

    /// Inner padding in points (0 for no padding).
    let padding: CGFloat

    /// Create a card with custom content.
    ///
    /// - Parameters:
    ///   - padding: Inner padding (default 16).
    ///   - content: Content view builder.
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .if(padding > 0) { view in
            view.padding(padding)
        }
        .background(LinkMeColors.surface)
        .cornerRadius(LinkMeLayout.cardRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    Card {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Title")
                .font(.system(.headline, design: .default))
                .foregroundColor(LinkMeColors.ink)
            Text("This is card content")
                .font(.system(.body, design: .default))
                .foregroundColor(LinkMeColors.s600)
        }
    }
    .padding()
    .background(LinkMeColors.canvas)
}

import SwiftUI

/// A thin horizontal line separator.
///
/// Neutral slate-200 color. Supports optional left inset for aligned separators.
struct Divider: View {
    /// Left edge inset in points (default 0).
    let inset: CGFloat

    /// Create a divider.
    ///
    /// - Parameters:
    ///   - inset: Left padding for the line (default 0).
    init(inset: CGFloat = 0) {
        self.inset = inset
    }

    var body: some View {
        Rectangle()
            .fill(LinkMeColors.s200)
            .frame(height: 1)
            .padding(.leading, inset)
    }
}

#Preview {
    VStack(spacing: 0) {
        Text("Item 1")
            .padding()
        Divider()
        Text("Item 2")
            .padding()
        Divider(inset: 68)
        Text("Item 3 (with inset)")
            .padding()
    }
}

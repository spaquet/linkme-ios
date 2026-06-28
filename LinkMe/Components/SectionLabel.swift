import SwiftUI

/// A small uppercase section header label.
///
/// Used to mark section titles in lists and grouped content.
/// Slate-500 color, semibold, small uppercase with letter spacing.
struct SectionLabel: View {
    /// Label text.
    let text: String

    /// Create a section label.
    ///
    /// - Parameters:
    ///   - text: Label text (will be uppercased).
    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11.5, weight: .semibold, design: .default))
            .tracking(0.08)
            .textCase(.uppercase)
            .foregroundColor(LinkMeColors.s500)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        SectionLabel("Up next")
        SectionLabel("Later today")
        SectionLabel("Needs you")
    }
    .padding()
}

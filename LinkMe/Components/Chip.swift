import SwiftUI

/// A small badge or tag chip with optional icon.
///
/// Displays a label with configurable tone and optional SF Symbol icon.
/// Used for tags, labels, and small informational badges.
struct Chip: View {
    /// Label text.
    let label: String

    /// Chip color tone.
    let tone: ChipTone

    /// Optional SF Symbol icon name.
    let icon: String?

    /// Chip color tone options.
    enum ChipTone {
        /// Neutral slate tone.
        case slate
        /// Teal (on-device/AI signal).
        case teal
        /// Amber accent.
        case amber
        /// Dark ink/text tone.
        case ink
        /// White background.
        case white
    }

    /// Create a chip.
    ///
    /// - Parameters:
    ///   - label: Chip text.
    ///   - tone: Color tone (default slate).
    ///   - icon: Optional SF Symbol name.
    init(_ label: String, tone: ChipTone = .slate, icon: String? = nil) {
        self.label = label
        self.tone = tone
        self.icon = icon
    }

    private func colors() -> (bg: Color, fg: Color, border: Color) {
        switch tone {
        case .slate: return (LinkMeColors.s100, LinkMeColors.s600, LinkMeColors.s200)
        case .teal: return (LinkMeColors.t50, LinkMeColors.t700, LinkMeColors.t200)
        case .amber: return (LinkMeColors.amber50, LinkMeColors.amber600, LinkMeColors.amber100)
        case .ink: return (LinkMeColors.ink, .white, LinkMeColors.ink)
        case .white: return (.white, LinkMeColors.s600, LinkMeColors.s200)
        }
    }

    var body: some View {
        let colors = colors()
        HStack(spacing: 5) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
            }
            Text(label)
                .font(.system(size: 12.5, weight: .medium, design: .default))
        }
        .foregroundColor(colors.fg)
        .frame(height: 26)
        .padding(.horizontal, 10)
        .background(colors.bg)
        .border(colors.border, width: 1)
        .cornerRadius(999)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            Chip("Slate")
            Chip("Teal", tone: .teal)
            Chip("Amber", tone: .amber)
        }
        HStack(spacing: 8) {
            Chip("Ink", tone: .ink)
            Chip("With icon", tone: .teal, icon: "star.fill")
        }
    }
    .padding()
}

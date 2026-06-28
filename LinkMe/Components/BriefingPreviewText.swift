import SwiftUI

/// Two-line briefing preview with emphasized keyword.
///
/// Displays talking points in a structured format: prefix + emphasized word + suffix + second line.
/// Used in "Up Next" section of Today view.
struct BriefingPreviewText: View {
    /// Text before the emphasized part.
    let prefix: String

    /// Word or phrase to emphasize (bold, ink color).
    let emphasis: String

    /// Text after emphasis on first line.
    let firstLineSuffix: String

    /// Second line of text.
    let secondLine: String

    /// Create a briefing preview.
    ///
    /// - Parameters:
    ///   - prefix: First part of text.
    ///   - emphasis: Emphasized word (bolded).
    ///   - firstLineSuffix: Rest of first line.
    ///   - secondLine: Second line.
    init(
        prefix: String = "Lead with the ",
        emphasis: String = "fund close",
        firstLineSuffix: String = ". He owes you",
        secondLine: String = "the memo; you offered an intro."
    ) {
        self.prefix = prefix
        self.emphasis = emphasis
        self.firstLineSuffix = firstLineSuffix
        self.secondLine = secondLine
    }

    var body: some View {
        Text("\(Text(prefix))\(Text(emphasis).fontWeight(.semibold).foregroundStyle(LinkMeColors.ink))\(Text(firstLineSuffix))\n\(secondLine)")
            .font(.system(size: 14, design: .default))
            .foregroundStyle(LinkMeColors.s700)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HStack(alignment: .center, spacing: 12) {
        Avatar(name: "Marcus Chen", size: 44, tone: "teal")
        BriefingPreviewText()
    }
    .padding()
}

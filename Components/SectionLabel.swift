import SwiftUI

struct SectionLabel: View {
    let text: String

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

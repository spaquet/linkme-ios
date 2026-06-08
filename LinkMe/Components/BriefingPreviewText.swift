import SwiftUI

struct BriefingPreviewText: View {
    let prefix: String
    let emphasis: String
    let firstLineSuffix: String
    let secondLine: String

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

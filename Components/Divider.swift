import SwiftUI

struct Divider: View {
    let inset: CGFloat

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

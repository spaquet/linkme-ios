import SwiftUI

struct OnDeviceChip: View {
    let label: String

    init(_ label: String = "On this device") {
        self.label = label
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock")
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.system(size: 11.5, weight: .semibold, design: .default))
        }
        .foregroundColor(LinkMeColors.t700)
        .frame(height: 24)
        .padding(.horizontal, 9)
        .background(LinkMeColors.t50)
        .border(LinkMeColors.t200, width: 1)
        .cornerRadius(999)
    }
}

#Preview {
    VStack(spacing: 12) {
        OnDeviceChip()
        OnDeviceChip("Private on device")
    }
    .padding()
}

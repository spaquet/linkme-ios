import SwiftUI

struct Avatar: View {
    let name: String
    let size: CGFloat
    let tone: String?
    let ring: Bool
    let initials: String?

    init(name: String, size: CGFloat = 44, tone: String? = nil, ring: Bool = false, initials: String? = nil) {
        self.name = name
        self.size = size
        self.tone = tone ?? Self.toneFor(name)
        self.ring = ring
        self.initials = initials
    }

    init(firstName: String, lastName: String? = nil, size: CGFloat = 44, tone: String? = nil, ring: Bool = false, initials: String? = nil) {
        let fullName = lastName.map { "\(firstName) \($0)" } ?? firstName
        self.name = fullName
        self.size = size
        self.tone = tone ?? Self.toneFor(fullName)
        self.ring = ring
        self.initials = initials
    }

    private static func toneFor(_ name: String) -> String {
        let tones = ["teal", "slate", "amber", "indigo", "rose", "sky"]
        guard let firstChar = name.trimmingCharacters(in: .whitespaces).first?.uppercased().first?.asciiValue else {
            return tones[0]
        }
        return tones[Int(firstChar % UInt8(tones.count))]
    }

    private func toneColors() -> (bg: Color, fg: Color) {
        switch tone {
        case "teal": return (LinkMeColors.t100, LinkMeColors.t700)
        case "slate": return (LinkMeColors.s200, LinkMeColors.s700)
        case "amber": return (LinkMeColors.amber100, LinkMeColors.amber600)
        case "indigo": return (Color(#colorLiteral(red: 0.88, green: 0.90, blue: 1.00, alpha: 1)), Color(#colorLiteral(red: 0.26, green: 0.22, blue: 0.79, alpha: 1)))
        case "rose": return (Color(#colorLiteral(red: 1.00, green: 0.89, blue: 0.90, alpha: 1)), Color(#colorLiteral(red: 0.75, green: 0.07, blue: 0.24, alpha: 1)))
        case "sky": return (Color(#colorLiteral(red: 0.88, green: 0.95, blue: 0.99, alpha: 1)), Color(#colorLiteral(red: 0.01, green: 0.41, blue: 0.63, alpha: 1)))
        default: return (LinkMeColors.s200, LinkMeColors.s700)
        }
    }

    private var computedInitials: String {
        initials ?? PersonModel.computeInitials(name)
    }

    var body: some View {
        let colors = toneColors()
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32)
                .fill(colors.bg)

            Text(computedInitials)
                .font(.system(size: size * 0.36, weight: .semibold, design: .default))
                .foregroundColor(colors.fg)
        }
        .frame(width: size, height: size)
        .if(ring) { view in
            view.overlay(
                RoundedRectangle(cornerRadius: size * 0.32)
                    .strokeBorder(LinkMeColors.t200, lineWidth: 2)
            )
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            Avatar(name: "Marcus Chen", size: 44)
            Avatar(name: "Sarah Johnson", size: 44)
            Avatar(name: "Alex Smith", size: 44)
        }
        HStack(spacing: 16) {
            Avatar(name: "Marcus Chen", size: 56, ring: true)
        }
    }
    .padding()
}

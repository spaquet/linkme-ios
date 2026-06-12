import SwiftUI

struct FloatingPopover<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isPresented = false
                        }
                    }

                VStack(spacing: 0) {
                    content
                }
                .background(LinkMeColors.surface)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 48)
                .padding(.trailing, 16)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
        }
    }
}

struct PopoverItem: View {
    let icon: String
    let label: String
    let isDestructive: Bool
    let action: () -> Void
    let isLast: Bool

    var textColor: Color {
        isDestructive ? LinkMeColors.rose500 : LinkMeColors.ink
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 18)

                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundColor(textColor)
        }

        if !isLast {
            Divider()
                .padding(.leading, 40)
                .padding(.vertical, 0)
        }
    }
}

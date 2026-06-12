import SwiftUI

struct ActionMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onEnrich: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            VStack {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(LinkMeColors.s300)
                    .frame(width: 40, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)

            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("Actions")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .tracking(-0.02)
                    .foregroundColor(LinkMeColors.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Action buttons
            VStack(spacing: 10) {
                ActionButton(
                    icon: "wand.and.stars",
                    label: "Enrich",
                    variant: .primary,
                    action: {
                        onEnrich()
                        dismiss()
                    }
                )

                ActionButton(
                    icon: "pencil",
                    label: "Edit",
                    variant: .secondary,
                    action: {
                        onEdit()
                        dismiss()
                    }
                )

                ActionButton(
                    icon: "trash",
                    label: "Delete Contact",
                    variant: .destructive,
                    action: {
                        onDelete()
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            Spacer()
        }
        .background(LinkMeColors.canvas)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let label: String
    let variant: Variant
    let action: () -> Void

    enum Variant {
        case primary
        case secondary
        case destructive
    }

    var backgroundColor: Color {
        switch variant {
        case .primary: return LinkMeColors.ink
        case .secondary: return LinkMeColors.surface
        case .destructive: return LinkMeColors.rose50
        }
    }

    var textColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return LinkMeColors.ink
        case .destructive: return LinkMeColors.rose500
        }
    }

    var borderColor: Color {
        switch variant {
        case .primary: return LinkMeColors.ink
        case .secondary: return LinkMeColors.s200
        case .destructive: return LinkMeColors.rose400
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .default))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .border(borderColor, width: 1)
            .cornerRadius(14)
        }
    }
}

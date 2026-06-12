import SwiftUI

struct SortMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSort: PersonSortOption
    let onSort: (PersonSortOption) -> Void

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
                Text("Sort by")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .tracking(-0.02)
                    .foregroundColor(LinkMeColors.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Sort options
            VStack(spacing: 0) {
                ForEach(PersonSortOption.allCases, id: \.id) { option in
                    Button(action: {
                        selectedSort = option
                        onSort(option)
                        dismiss()
                    }) {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.rawValue)
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.ink)
                            }

                            Spacer()

                            if selectedSort == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(LinkMeColors.t600)
                            } else {
                                Circle()
                                    .stroke(LinkMeColors.s300, lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }

                    if option != PersonSortOption.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(LinkMeColors.surface)
            .cornerRadius(LinkMeLayout.cardRadius)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            Spacer()
        }
        .background(LinkMeColors.canvas)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

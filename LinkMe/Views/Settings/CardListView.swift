import SwiftUI

struct CardListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards: [CardModel] = []
    @State private var cardToEdit: CardModel?
    @State private var showCardEditView = false
    @State private var showDeleteConfirmation = false
    @State private var cardToDelete: CardModel?

    var body: some View {
        NavigationStack {
            ZStack {
                LinkMeColors.canvas
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LinkMeColors.s500)
                                .frame(width: 32, height: 32)
                                .background(LinkMeColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                )
                        }

                        Spacer()

                        Button(action: {
                            cardToEdit = nil
                            showCardEditView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LinkMeColors.s500)
                                .frame(width: 32, height: 32)
                                .background(LinkMeColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your cards")
                            .font(.system(size: 28, weight: .semibold, design: .default))
                            .tracking(-0.02)
                            .foregroundColor(LinkMeColors.ink)

                        Text("Manage your profile cards and select a default")
                            .font(.system(size: 13.5, weight: .regular, design: .default))
                            .foregroundColor(LinkMeColors.s500)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    ScrollView {
                        VStack(spacing: 14) {
                            if cards.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.text.rectangle")
                                        .font(.system(size: 36, weight: .light))
                                        .foregroundColor(LinkMeColors.s300)

                                    Text("No cards yet")
                                        .font(.system(size: 15, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s500)

                                    Text("Create your first card to get started")
                                        .font(.system(size: 13, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                Card(padding: 0) {
                                    VStack(spacing: 0) {
                                        ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                                            CardRow(
                                                card: card,
                                                isDefault: card.isDefault,
                                                onSelect: { setDefault(card) },
                                                onEdit: {
                                                    cardToEdit = card
                                                    showCardEditView = true
                                                },
                                                onDelete: {
                                                    cardToDelete = card
                                                    showDeleteConfirmation = true
                                                }
                                            )

                                            if index < cards.count - 1 {
                                                Divider()
                                                    .padding(.horizontal, 14)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 18)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationDestination(isPresented: $showCardEditView) {
                CardEditView(card: cardToEdit)
            }
            .alert("Delete Card?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                }
            } message: {
                Text("This card will be deleted permanently.")
            }
            .onAppear {
                loadCards()
            }
            .onChange(of: showCardEditView) { _, isShowing in
                if !isShowing {
                    loadCards()
                }
            }
        }
    }

    private func loadCards() {
        cards = DatabaseManager.shared.fetchCards()
    }

    private func setDefault(_ card: CardModel) {
        DatabaseManager.shared.setDefaultCard(cardId: card.id)
        loadCards()
    }

    private func deleteCard(_ card: CardModel) {
        DatabaseManager.shared.deleteCard(cardId: card.id)
        loadCards()
        cardToDelete = nil
    }
}

struct CardRow: View {
    let card: CardModel
    let isDefault: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSelect) {
                Circle()
                    .strokeBorder(isDefault ? LinkMeColors.t500 : LinkMeColors.s300, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(LinkMeColors.t500)
                            .frame(width: 12, height: 12)
                            .opacity(isDefault ? 1 : 0)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)

                Text("\(card.role) · \(card.company)")
                    .font(.system(size: 12.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 8) {
                Menu {
                    Button(action: onEdit) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                    }

                    Button(role: .destructive, action: onDelete) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.s400)
                }
            }
        }
        .padding(14)
    }
}

#Preview {
    CardListView()
}

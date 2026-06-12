import SwiftUI

struct CardEditView: View {
    @Environment(\.dismiss) var dismiss
    let card: CardModel?

    @State private var name = ""
    @State private var nickname = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var role = ""
    @State private var company = ""
    @State private var tagline = ""
    @State private var location = ""
    @State private var timezone = ""
    @State private var pronouns = ""
    @State private var isDefault = false

    @State private var showChatAppsModal = false
    @State private var showSocialLinksModal = false
    @State private var showPaymentLinksModal = false

    @FocusState private var focusedField: CardField?

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(card == nil ? "New card" : "Edit card")
                                .font(.system(size: 26, weight: .semibold, design: .default))
                                .tracking(-0.025)
                                .foregroundColor(LinkMeColors.ink)

                            Text(card == nil ? "Create a new profile card." : "Update this card's information.")
                                .font(.system(size: 15.5, design: .default))
                                .foregroundColor(LinkMeColors.s500)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                        // Live preview
                        Card(padding: 0) {
                            VStack(spacing: 0) {
                                HStack(spacing: 6) {
                                    Spacer()
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .opacity(0.9)
                                    Text("Live preview")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(.white)
                                        .opacity(0.9)
                                    .padding(.trailing, 12)
                                }
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [LinkMeColors.t500, LinkMeColors.t700]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))

                                VStack(alignment: .leading, spacing: 0) {
                                    Avatar(firstName: firstName.isEmpty ? "You" : firstName, lastName: lastName.isEmpty ? nil : lastName, size: 56, tone: "teal", ring: true)
                                        .padding(.bottom, 8)

                                    VStack(alignment: .leading, spacing: -2) {
                                        let displayName = firstName.isEmpty ? "Your name" : (lastName.isEmpty ? firstName : "\(firstName) \(lastName)")
                                        Text(displayName)
                                            .font(.system(size: 18, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.ink)

                                        Text("\(role.isEmpty ? "Role" : role) · \(company.isEmpty ? "Company" : company)")
                                            .font(.system(size: 13, design: .default))
                                            .foregroundColor(LinkMeColors.s500)
                                    }

                                    Text(tagline.isEmpty ? "One line about you" : tagline)
                                        .font(.system(size: 13, design: .default))
                                        .foregroundColor(tagline.isEmpty ? LinkMeColors.s400 : LinkMeColors.s600)
                                        .lineLimit(2)
                                        .padding(.top, 7)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Card name field
                        VStack(spacing: 11) {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 2) {
                                    Text("CARD NAME")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)
                                    Text("*")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.rose500)
                                }

                                TextField("e.g., Work Card", text: $name)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, design: .default))
                                    .foregroundColor(LinkMeColors.ink)
                                    .accentColor(LinkMeColors.t500)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .firstName }
                                    .onChange(of: name) { _, newValue in
                                        if !newValue.isEmpty && focusedField == .name && firstName.isEmpty {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                focusedField = .firstName
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 12)
                                    .frame(height: 46)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .name ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                    )
                            }
                            .padding(.horizontal, 16)

                            // Default card toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DEFAULT CARD")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    Text("Use this card when sharing your profile")
                                        .font(.system(size: 12.5, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                }

                                Spacer()

                                Toggle("", isOn: $isDefault)
                                    .tint(LinkMeColors.t500)
                            }
                            .padding(.horizontal, 13)
                            .padding(.vertical, 12)
                            .frame(height: 46)
                            .background(LinkMeColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }

                        // Required fields
                        VStack(spacing: 11) {
                            HStack(spacing: 11) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack(spacing: 2) {
                                        Text("FIRST NAME")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.s400)
                                            .tracking(0.04)
                                        Text("*")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.rose500)
                                    }

                                    TextField("First name", text: $firstName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .textContentType(.givenName)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .firstName)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .lastName }
                                        .onChange(of: firstName) { _, newValue in
                                            if !newValue.isEmpty && focusedField == .firstName && lastName.isEmpty {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    focusedField = .lastName
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .firstName ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("LAST NAME")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Last name", text: $lastName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .textContentType(.familyName)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .lastName)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .email }
                                        .onChange(of: lastName) { _, newValue in
                                            if !newValue.isEmpty && focusedField == .lastName && email.isEmpty {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    focusedField = .email
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .lastName ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 2) {
                                    Text("EMAIL")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)
                                    Text("*")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.rose500)
                                }

                                TextField("you@company.com", text: $email)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, design: .default))
                                    .foregroundColor(LinkMeColors.ink)
                                    .accentColor(LinkMeColors.t500)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .role }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 12)
                                    .frame(height: 46)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                    )
                            }
                            .padding(.horizontal, 16)
                        }

                        // Optional fields
                        VStack(spacing: 11) {
                            HStack(spacing: 11) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("ROLE")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Founder & CEO", text: $role)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .role)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .company }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .role ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("COMPANY")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Company", text: $company)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .textContentType(.organizationName)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .company)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .tagline }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .company ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("TAGLINE")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                TextField("Your tagline", text: $tagline)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, design: .default))
                                    .foregroundColor(LinkMeColors.ink)
                                    .accentColor(LinkMeColors.t500)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .tagline)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .location }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 12)
                                    .frame(height: 46)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .tagline ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                    )
                            }
                            .padding(.horizontal, 16)

                            HStack(spacing: 11) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("PHONE")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Phone", text: $phone)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .phone)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .location }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .phone ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("LOCATION")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Location", text: $location)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .textContentType(.addressCity)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .location)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .timezone }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .location ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)

                            HStack(spacing: 11) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("TIMEZONE")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("UTC-8", text: $timezone)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .timezone)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .pronouns }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .timezone ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("PRONOUNS")
                                        .font(.system(size: 10.5, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.s400)
                                        .tracking(0.04)

                                    TextField("Pronouns", text: $pronouns)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .pronouns)
                                        .submitLabel(.done)
                                        .onSubmit { focusedField = nil }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                        .frame(height: 46)
                                        .background(LinkMeColors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .pronouns ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Advanced fields section
                        VStack(spacing: 11) {
                            Text("ADVANCED")
                                .font(.system(size: 10.5, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.s400)
                                .tracking(0.04)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)

                            HStack(spacing: 11) {
                                Button(action: { showChatAppsModal = true }) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Chat Apps")
                                            .font(.system(size: 14, design: .default))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .frame(height: 46)
                                    .padding(.horizontal, 13)
                                    .foregroundColor(LinkMeColors.t500)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                                }

                                Button(action: { showSocialLinksModal = true }) {
                                    HStack {
                                        Image(systemName: "link")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Social")
                                            .font(.system(size: 14, design: .default))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .frame(height: 46)
                                    .padding(.horizontal, 13)
                                    .foregroundColor(LinkMeColors.t500)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                                }

                                Button(action: { showPaymentLinksModal = true }) {
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Payment")
                                            .font(.system(size: 14, design: .default))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .frame(height: 46)
                                    .padding(.horizontal, 13)
                                    .foregroundColor(LinkMeColors.t500)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: saveCard) {
                        Text(card == nil ? "Create card" : "Save card")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(.white)
                            .background(LinkMeColors.ink)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                }
                .padding(16)
                .background(LinkMeColors.canvas)
            }
        }
        .onAppear {
            if let card = card {
                name = card.name
                nickname = card.nickname ?? ""
                firstName = card.firstName
                lastName = card.lastName ?? ""
                email = card.email
                phone = card.phone ?? ""
                role = card.role
                company = card.company
                tagline = card.tagline ?? ""
                location = card.location ?? ""
                timezone = card.timezone ?? ""
                pronouns = card.pronouns ?? ""
                isDefault = card.isDefault
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveCard() {
        let cardName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "\(firstName)'s Card" : name
        let savedCard = CardModel(
            id: card?.id ?? UUID().uuidString,
            name: cardName,
            nickname: nickname.isEmpty ? nil : nickname,
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            role: role,
            company: company,
            bio: nil,
            tagline: tagline.isEmpty ? nil : tagline,
            location: location.isEmpty ? nil : location,
            timezone: timezone.isEmpty ? nil : timezone,
            pronouns: pronouns.isEmpty ? nil : pronouns,
            isDefault: isDefault,
            sharedPublicly: card?.sharedPublicly ?? false
        )

        if card == nil {
            DatabaseManager.shared.insertCard(savedCard)
        } else {
            DatabaseManager.shared.updateCard(savedCard)
            if isDefault {
                DatabaseManager.shared.setDefaultCard(cardId: savedCard.id)
            }
        }

        dismiss()
    }
}

enum CardField: Hashable {
    case name
    case firstName
    case lastName
    case email
    case role
    case company
    case tagline
    case phone
    case location
    case timezone
    case pronouns
}

#Preview {
    CardEditView(card: nil)
}

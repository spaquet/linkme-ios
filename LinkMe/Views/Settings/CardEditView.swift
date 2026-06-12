import SwiftUI

struct CardEditView: View {
    @Environment(\.dismiss) var dismiss
    let card: CardModel?
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
    @FocusState private var focusedField: CardField?

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !role.trimmingCharacters(in: .whitespaces).isEmpty &&
        !company.trimmingCharacters(in: .whitespaces).isEmpty
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

                        VStack(spacing: 11) {
                            // First name & Last name
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

                            // Email
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

                                TextField(
                                    "",
                                    text: $email,
                                    prompt: Text("you@company.com")
                                        .foregroundColor(LinkMeColors.s500)
                                )
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

                            // Role & Company
                            HStack(spacing: 11) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack(spacing: 2) {
                                        Text("ROLE")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.s400)
                                            .tracking(0.04)
                                        Text("*")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.rose500)
                                    }

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
                                    HStack(spacing: 2) {
                                        Text("COMPANY")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.s400)
                                            .tracking(0.04)
                                        Text("*")
                                            .font(.system(size: 10.5, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.rose500)
                                    }

                                    TextField("Company", text: $company)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .textContentType(.organizationName)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .company)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .phone }
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

                            // Tagline
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
                                    .onSubmit { focusedField = .phone }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 12)
                                    .frame(height: 46)
                                    .background(LinkMeColors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .tagline ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                    )
                            }

                            // Phone & Location
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

                            // Timezone & Pronouns
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
                                        .submitLabel(.done)
                                        .onSubmit { focusedField = nil }
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
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .padding(.bottom, 20)
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
            }
        }
    }

    private func saveCard() {
        let savedCard = CardModel(
            id: card?.id ?? UUID().uuidString,
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
            isDefault: card?.isDefault ?? false,
            sharedPublicly: card?.sharedPublicly ?? false
        )

        if card == nil {
            DatabaseManager.shared.insertCard(savedCard)
        } else {
            DatabaseManager.shared.updateCard(savedCard)
        }

        dismiss()
    }
}

enum CardField: Hashable {
    case firstName
    case lastName
    case email
    case phone
    case role
    case company
    case tagline
    case location
    case timezone
    case pronouns
}

#Preview {
    CardEditView(card: nil)
}

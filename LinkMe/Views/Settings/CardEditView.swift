import SwiftUI
import CoreLocation
import Combine

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
    @State private var isDefault = false

    @State private var socialLinks: [SocialLink] = []
    @State private var paymentLinks: [PaymentLink] = []
    @State private var chatApps: [ChatApp] = []

    @State private var showLocationSheet = false
    @State private var showTimezoneSheet = false
    @State private var showChatAppsModal = false
    @State private var showSocialLinksModal = false
    @State private var showPaymentLinksModal = false

    @FocusState private var focusedField: CardField?

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
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

                            Text(card == nil ? "Create a new profile card." : "Update \(card?.name ?? "this card")")
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

                                ZStack(alignment: .leading) {
                                    if name.isEmpty {
                                        Text("e.g., Work Card")
                                            .foregroundColor(LinkMeColors.s200)
                                            .font(.system(size: 15, design: .default))
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 12)
                                    }

                                    TextField("", text: $name)
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
                                }
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

                                    ZStack(alignment: .leading) {
                                        if firstName.isEmpty {
                                            Text("First name")
                                                .foregroundColor(LinkMeColors.s200)
                                                .font(.system(size: 15, design: .default))
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 12)
                                        }

                                        TextField("", text: $firstName)
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
                                    }
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

                                    ZStack(alignment: .leading) {
                                        if lastName.isEmpty {
                                            Text("Last name")
                                                .foregroundColor(LinkMeColors.s200)
                                                .font(.system(size: 15, design: .default))
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 12)
                                        }

                                        TextField("", text: $lastName)
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
                                    }
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
                                Text("EMAIL")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                ZStack(alignment: .leading) {
                                    if email.isEmpty {
                                        Text("you@company.com")
                                            .foregroundColor(LinkMeColors.s200)
                                            .font(.system(size: 15, design: .default))
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 12)
                                    }

                                    TextField("", text: $email)
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
                                }
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

                                    ZStack(alignment: .leading) {
                                        if role.isEmpty {
                                            Text("Founder & CEO")
                                                .foregroundColor(LinkMeColors.s200)
                                                .font(.system(size: 15, design: .default))
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 12)
                                        }

                                        TextField("", text: $role)
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
                                    }
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

                                    ZStack(alignment: .leading) {
                                        if company.isEmpty {
                                            Text("Company")
                                                .foregroundColor(LinkMeColors.s200)
                                                .font(.system(size: 15, design: .default))
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 12)
                                        }

                                        TextField("", text: $company)
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
                                    }
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

                                ZStack(alignment: .leading) {
                                    if tagline.isEmpty {
                                        Text("Your tagline")
                                            .foregroundColor(LinkMeColors.s200)
                                            .font(.system(size: 15, design: .default))
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 12)
                                    }

                                    TextField("", text: $tagline)
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
                                }
                                .frame(height: 46)
                                .background(LinkMeColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .tagline ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("PHONE")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                ZStack(alignment: .leading) {
                                    if phone.isEmpty {
                                        Text("Phone")
                                            .foregroundColor(LinkMeColors.s200)
                                            .font(.system(size: 15, design: .default))
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 12)
                                    }

                                    TextField("", text: $phone)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .accentColor(LinkMeColors.t500)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .phone)
                                        .submitLabel(.done)
                                        .onSubmit { focusedField = nil }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 12)
                                }
                                .frame(height: 46)
                                .background(LinkMeColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .phone ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("LOCATION")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                Card {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(location.isEmpty ? "Select location" : location)
                                                .font(.system(size: 15, design: .default))
                                                .foregroundColor(location.isEmpty ? LinkMeColors.s400 : LinkMeColors.ink)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s400)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .onTapGesture {
                                    showLocationSheet = true
                                }
                            }
                            .padding(.horizontal, 16)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("TIMEZONE")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                Card {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(timezone.isEmpty ? "Select timezone" : timezone)
                                                .font(.system(size: 15, design: .default))
                                                .foregroundColor(timezone.isEmpty ? LinkMeColors.s400 : LinkMeColors.ink)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s400)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .onTapGesture {
                                    showTimezoneSheet = true
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

                            VStack(spacing: 11) {
                                Card {
                                    HStack {
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(LinkMeColors.t500)
                                        Text("Chat Apps")
                                            .font(.system(size: 15, design: .default))
                                            .foregroundColor(LinkMeColors.ink)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s400)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .onTapGesture {
                                    showChatAppsModal = true
                                }

                                Card {
                                    HStack {
                                        Image(systemName: "link")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(LinkMeColors.t500)
                                        Text("Social Links")
                                            .font(.system(size: 15, design: .default))
                                            .foregroundColor(LinkMeColors.ink)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s400)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .onTapGesture {
                                    showSocialLinksModal = true
                                }

                                Card {
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(LinkMeColors.t500)
                                        Text("Payment Links")
                                            .font(.system(size: 15, design: .default))
                                            .foregroundColor(LinkMeColors.ink)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(LinkMeColors.s400)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .onTapGesture {
                                    showPaymentLinksModal = true
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
        .sheet(isPresented: $showLocationSheet) {
            LocationPickerSheet(location: $location, isPresented: $showLocationSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTimezoneSheet) {
            TimezonePickerSheet(timezone: $timezone, isPresented: $showTimezoneSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showChatAppsModal) {
            ChatAppsSheet(chatApps: $chatApps, isPresented: $showChatAppsModal)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSocialLinksModal) {
            SocialLinksSheet(socialLinks: $socialLinks, isPresented: $showSocialLinksModal)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPaymentLinksModal) {
            PaymentLinksSheet(paymentLinks: $paymentLinks, isPresented: $showPaymentLinksModal)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
                isDefault = card.isDefault
                socialLinks = card.socialLinks
                paymentLinks = card.paymentLinks
                chatApps = card.chatApps
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveCard() {
        let cardName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "\(firstName)'s Card" : name
        let isNewCard = card == nil
        let existingCards = DatabaseManager.shared.fetchCards()
        let shouldBeDefault = isNewCard ? (existingCards.isEmpty || isDefault) : isDefault

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
            pronouns: nil,
            socialLinks: socialLinks,
            paymentLinks: paymentLinks,
            chatApps: chatApps,
            isDefault: shouldBeDefault,
            sharedPublicly: card?.sharedPublicly ?? false
        )

        if isNewCard {
            DatabaseManager.shared.insertCard(savedCard)
            if shouldBeDefault {
                DatabaseManager.shared.setDefaultCard(cardId: savedCard.id)
            }
        } else {
            DatabaseManager.shared.updateCard(savedCard)
            if shouldBeDefault {
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
}

struct LocationPickerSheet: View {
    @Binding var location: String
    @Binding var isPresented: Bool
    @State private var locationInput = ""
    @State private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 0) {
            Text("Where are you?")
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.s500)

                        ZStack(alignment: .leading) {
                            if locationInput.isEmpty {
                                Text("Paris, France")
                                    .foregroundColor(LinkMeColors.s200)
                                    .font(.system(size: 17, design: .default))
                            }

                            TextField("", text: $locationInput)
                                .textFieldStyle(.plain)
                                .font(.system(size: 17, design: .default))
                                .foregroundColor(LinkMeColors.ink)
                                .accentColor(LinkMeColors.t500)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(LinkMeColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinkMeColors.s200, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Format examples:")
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundColor(LinkMeColors.s500)

                        Text("Paris, France • Los Angeles, CA, USA • Mumbai, India")
                            .font(.system(size: 12, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()
                    .padding(.vertical, 8)

                Button(action: {
                    if !locationManager.isLoading {
                        locationManager.requestLocation()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(LinkMeColors.t500)

                        Text(locationManager.isLoading ? "Getting location..." : "Use device location")
                            .font(.system(size: 17, design: .default))
                            .foregroundColor(LinkMeColors.ink)

                        Spacer()

                        if locationManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8, anchor: .center)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(LinkMeColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinkMeColors.s200, lineWidth: 1)
                    )
                }
                .disabled(locationManager.isLoading)
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    if !locationInput.isEmpty {
                        location = locationInput.trimmingCharacters(in: .whitespaces)
                        isPresented = false
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(12)
                }
                .disabled(locationInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(locationInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
            .padding(20)
            .background(LinkMeColors.canvas)
        }
        .background(LinkMeColors.canvas)
        .onAppear {
            locationInput = location
        }
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            if let newLocation = newLocation {
                locationInput = newLocation
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: String?
    @Published var isLoading = false
    private var isRequestingAfterAuth = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            isRequestingAfterAuth = true
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isLoading = true
            locationManager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if isRequestingAfterAuth && (status == .authorizedWhenInUse || status == .authorizedAlways) {
            isRequestingAfterAuth = false
            isLoading = true
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                var components: [String] = []

                if let city = placemark.locality {
                    components.append(city)
                }
                if let state = placemark.administrativeArea {
                    components.append(state)
                }
                if let country = placemark.country {
                    components.append(country)
                }

                let formattedLocation = components.joined(separator: ", ")
                DispatchQueue.main.async {
                    self?.currentLocation = formattedLocation
                    self?.isLoading = false
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

struct TimezonePickerSheet: View {
    @Binding var timezone: String
    @Binding var isPresented: Bool
    @State private var searchText = ""

    private let timezones = TimeZone.knownTimeZoneIdentifiers.sorted()
    private let deviceTimezone = TimeZone.current.identifier

    private var filteredTimezones: [String] {
        if searchText.isEmpty {
            return timezones
        }
        return timezones.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private func timeInfoForTimezone(_ tzIdentifier: String) -> (time: String, offset: String) {
        guard let tz = TimeZone(identifier: tzIdentifier) else {
            return ("--:--", "UTC")
        }

        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = tz

        let components = calendar.dateComponents([.hour, .minute], from: now)
        let hour = String(format: "%02d", components.hour ?? 0)
        let minute = String(format: "%02d", components.minute ?? 0)
        let time = "\(hour):\(minute)"

        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let mins = (abs(seconds) % 3600) / 60
        let sign = hours >= 0 ? "+" : ""

        let offset: String
        if mins == 0 {
            offset = "UTC\(sign)\(hours)"
        } else {
            offset = "UTC\(sign)\(hours):\(String(format: "%02d", mins))"
        }

        return (time, offset)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Timezone")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                    Spacer()
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.s400)

                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Search")
                                .foregroundColor(LinkMeColors.s200)
                                .font(.system(size: 15, design: .default))
                        }

                        TextField("", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 15, design: .default))
                            .foregroundColor(LinkMeColors.ink)
                            .accentColor(LinkMeColors.t500)
                    }

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(LinkMeColors.s400)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(LinkMeColors.s100)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(filteredTimezones, id: \.self) { tz in
                            let (time, offset) = timeInfoForTimezone(tz)
                            let isSelected = timezone == tz
                            let isDeviceTimezone = tz == deviceTimezone

                            Button(action: {
                                timezone = tz
                                isPresented = false
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tz)
                                            .font(.system(size: 15, weight: .semibold, design: .default))
                                            .foregroundColor(LinkMeColors.ink)

                                        HStack(spacing: 8) {
                                            Text(time)
                                                .font(.system(size: 13, design: .monospaced))
                                                .foregroundColor(LinkMeColors.s600)

                                            Text("•")
                                                .foregroundColor(LinkMeColors.s400)

                                            Text(offset)
                                                .font(.system(size: 13, design: .default))
                                                .foregroundColor(LinkMeColors.s500)
                                        }
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(LinkMeColors.t500)
                                        } else if isDeviceTimezone {
                                            Text("Device")
                                                .font(.system(size: 11, weight: .semibold, design: .default))
                                                .foregroundColor(LinkMeColors.t500)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .id(tz)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onAppear {
                    if searchText.isEmpty {
                        proxy.scrollTo(deviceTimezone, anchor: .center)
                    }
                }
                .onChange(of: searchText) { _, newValue in
                    if newValue.isEmpty && filteredTimezones.contains(deviceTimezone) {
                        proxy.scrollTo(deviceTimezone, anchor: .center)
                    }
                }
            }

            VStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(LinkMeColors.canvas)
        }
        .background(LinkMeColors.canvas)
    }
}

struct ChatAppsSheet: View {
    @Binding var chatApps: [ChatApp]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Chat Apps")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                    Spacer()
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ChatAppType.allCases, id: \.self) { appType in
                            let existingApp = chatApps.first { $0.type == appType }
                            ChatAppInputRow(
                                appType: appType,
                                value: existingApp?.value ?? "",
                                onSave: { newValue in
                                    if let index = chatApps.firstIndex(where: { $0.type == appType }) {
                                        if newValue.isEmpty {
                                            chatApps.remove(at: index)
                                        } else {
                                            chatApps[index].value = newValue
                                        }
                                    } else if !newValue.isEmpty {
                                        chatApps.append(ChatApp(type: appType, value: newValue))
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(LinkMeColors.canvas)
        }
        .background(LinkMeColors.canvas)
    }
}

struct ChatAppInputRow: View {
    let appType: ChatAppType
    @State private var inputValue: String
    let onSave: (String) -> Void

    init(appType: ChatAppType, value: String, onSave: @escaping (String) -> Void) {
        self.appType = appType
        self.onSave = onSave
        _inputValue = State(initialValue: value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(appType.displayName)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s400)
                .tracking(0.04)

            HStack(spacing: 8) {
                Image(systemName: appType.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LinkMeColors.t500)

                ZStack(alignment: .leading) {
                    if inputValue.isEmpty {
                        Text(appType.placeholder)
                            .foregroundColor(LinkMeColors.s200)
                            .font(.system(size: 14, design: .default))
                    }

                    TextField("", text: $inputValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                        .accentColor(LinkMeColors.t500)
                        .onChange(of: inputValue) { _, _ in
                            onSave(inputValue)
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(LinkMeColors.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                )
            }
        }
    }
}

extension ChatAppType {
    var displayName: String {
        switch self {
        case .whatsapp: return "WhatsApp"
        case .wechat: return "WeChat"
        case .signal: return "Signal"
        case .telegram: return "Telegram"
        case .imessage: return "iMessage"
        }
    }

    var iconName: String {
        switch self {
        case .whatsapp: return "message.circle.fill"
        case .wechat: return "message.circle.fill"
        case .signal: return "message.circle.fill"
        case .telegram: return "message.circle.fill"
        case .imessage: return "message.circle.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .whatsapp: return "e.g., +1 (555) 123-4567"
        case .wechat: return "e.g., your_wechat_id"
        case .signal: return "e.g., +1 (555) 123-4567"
        case .telegram: return "e.g., @yourhandle or username"
        case .imessage: return "e.g., your@email.com"
        }
    }
}

struct SocialLinksSheet: View {
    @Binding var socialLinks: [SocialLink]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Social Links")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                    Spacer()
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(SocialLinkType.allCases, id: \.self) { linkType in
                            let existingLink = socialLinks.first { $0.type == linkType }
                            SocialLinkInputRow(
                                linkType: linkType,
                                value: existingLink?.value ?? "",
                                onSave: { newValue in
                                    if let index = socialLinks.firstIndex(where: { $0.type == linkType }) {
                                        if newValue.isEmpty {
                                            socialLinks.remove(at: index)
                                        } else {
                                            socialLinks[index].value = newValue
                                        }
                                    } else if !newValue.isEmpty {
                                        socialLinks.append(SocialLink(type: linkType, value: newValue))
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(LinkMeColors.canvas)
        }
        .background(LinkMeColors.canvas)
    }
}

struct SocialLinkInputRow: View {
    let linkType: SocialLinkType
    @State private var inputValue: String
    let onSave: (String) -> Void

    init(linkType: SocialLinkType, value: String, onSave: @escaping (String) -> Void) {
        self.linkType = linkType
        self.onSave = onSave
        _inputValue = State(initialValue: value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(linkType.displayName)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s400)
                .tracking(0.04)

            HStack(spacing: 8) {
                Image(systemName: linkType.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LinkMeColors.t500)

                ZStack(alignment: .leading) {
                    if inputValue.isEmpty {
                        Text(linkType.placeholder)
                            .foregroundColor(LinkMeColors.s200)
                            .font(.system(size: 14, design: .default))
                    }

                    TextField("", text: $inputValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                        .accentColor(LinkMeColors.t500)
                        .onChange(of: inputValue) { _, _ in
                            onSave(inputValue)
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(LinkMeColors.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                )
            }
        }
    }
}

extension SocialLinkType {
    var displayName: String {
        switch self {
        case .website: return "Website"
        case .blog: return "Blog"
        case .x: return "X / Twitter"
        case .instagram: return "Instagram"
        case .linkedin: return "LinkedIn"
        case .tiktok: return "TikTok"
        case .threads: return "Threads"
        case .bluesky: return "Bluesky"
        }
    }

    var iconName: String {
        switch self {
        case .website: return "globe"
        case .blog: return "book.fill"
        case .x: return "link.circle.fill"
        case .instagram: return "camera.fill"
        case .linkedin: return "link.circle.fill"
        case .tiktok: return "music.note"
        case .threads: return "link.circle.fill"
        case .bluesky: return "link.circle.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .website: return "https://yoursite.com"
        case .blog: return "https://medium.com/@yourhandle"
        case .x: return "@yourhandle"
        case .instagram: return "@yourhandle"
        case .linkedin: return "linkedin.com/in/yourprofile"
        case .tiktok: return "@yourhandle"
        case .threads: return "@yourhandle"
        case .bluesky: return "@yourhandle.bsky.social"
        }
    }
}

struct PaymentLinksSheet: View {
    @Binding var paymentLinks: [PaymentLink]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Payment Links")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                    Spacer()
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(PaymentLinkType.allCases, id: \.self) { paymentType in
                            let existingLink = paymentLinks.first { $0.type == paymentType }
                            PaymentLinkInputRow(
                                paymentType: paymentType,
                                value: existingLink?.value ?? "",
                                onSave: { newValue in
                                    if let index = paymentLinks.firstIndex(where: { $0.type == paymentType }) {
                                        if newValue.isEmpty {
                                            paymentLinks.remove(at: index)
                                        } else {
                                            paymentLinks[index].value = newValue
                                        }
                                    } else if !newValue.isEmpty {
                                        paymentLinks.append(PaymentLink(type: paymentType, value: newValue))
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(LinkMeColors.ink)
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(LinkMeColors.canvas)
        }
        .background(LinkMeColors.canvas)
    }
}

struct PaymentLinkInputRow: View {
    let paymentType: PaymentLinkType
    @State private var inputValue: String
    let onSave: (String) -> Void

    init(paymentType: PaymentLinkType, value: String, onSave: @escaping (String) -> Void) {
        self.paymentType = paymentType
        self.onSave = onSave
        _inputValue = State(initialValue: value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(paymentType.displayName)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(LinkMeColors.s400)
                .tracking(0.04)

            HStack(spacing: 8) {
                Image(systemName: paymentType.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LinkMeColors.t500)

                ZStack(alignment: .leading) {
                    if inputValue.isEmpty {
                        Text(paymentType.placeholder)
                            .foregroundColor(LinkMeColors.s200)
                            .font(.system(size: 14, design: .default))
                    }

                    TextField("", text: $inputValue)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, design: .default))
                        .foregroundColor(LinkMeColors.ink)
                        .accentColor(LinkMeColors.t500)
                        .onChange(of: inputValue) { _, _ in
                            onSave(inputValue)
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(LinkMeColors.surface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(LinkMeColors.s200, lineWidth: 1)
                )
            }
        }
    }
}

extension PaymentLinkType {
    var displayName: String {
        switch self {
        case .stripe: return "Stripe"
        case .venmo: return "Venmo"
        case .paypal: return "PayPal"
        case .square: return "Square Cash"
        case .cashapp: return "Cash App"
        }
    }

    var iconName: String {
        switch self {
        case .stripe: return "creditcard.fill"
        case .venmo: return "dollarsign.circle.fill"
        case .paypal: return "creditcard.fill"
        case .square: return "creditcard.fill"
        case .cashapp: return "dollarsign.circle.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .stripe: return "stripe.com/yourname"
        case .venmo: return "@yourname"
        case .paypal: return "yourname@email.com"
        case .square: return "cash.app/$yourname"
        case .cashapp: return "$yourname"
        }
    }
}

#Preview {
    CardEditView(card: nil)
}

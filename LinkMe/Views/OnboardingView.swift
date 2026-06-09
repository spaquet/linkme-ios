import SwiftUI

// Custom email input to control placeholder color
struct EmailInput: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.text = text
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: 15)
        field.textColor = UIColor(LinkMeColors.ink)
        field.tintColor = UIColor(LinkMeColors.t500)

        let placeholderColor = UIColor(LinkMeColors.s400)
        field.attributedPlaceholder = NSAttributedString(
            string: "you@company.com",
            attributes: [.foregroundColor: placeholderColor]
        )

        field.delegate = context.coordinator
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text

        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: $isFocused)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool

        init(text: Binding<String>, isFocused: Binding<Bool>) {
            self._text = text
            self._isFocused = isFocused
        }

        func textField(_ UITextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let newText = (UITextField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            self.text = newText
            return true
        }

        func textFieldDidEndEditing(_ UITextField: UITextField) {
            self.text = UITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            self.isFocused = false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFocused = true
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

enum OnboardingCardField: Hashable {
    case firstName
    case lastName
    case role
    case company
    case tagline
    case email
}

struct OnboardingView: View {
    let appState: AppState
    var onDone: () -> Void
    @State private var currentSlide = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var role = ""
    @State private var company = ""
    @State private var tagline = ""
    @State private var email = ""
    @FocusState private var focusedField: OnboardingCardField?

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            LinkMeColors.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 999)
                            .fill(i == currentSlide ? LinkMeColors.t500 : LinkMeColors.s300)
                            .frame(width: i == currentSlide ? 22 : 7, height: 7)
                            .animation(.easeInOut(duration: 0.25), value: currentSlide)
                    }
                    Spacer()
                    if currentSlide < 3 {
                        Button("Skip") {
                            withAnimation {
                                currentSlide = 3
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.s500)
                    }
                }
                .padding(20)
                .padding(.top, LinkMeLayout.statusBarHeight - 20)

                // Slide content
                Group {
                    switch currentSlide {
                    case 0:
                        WelcomeView()
                    case 1:
                        MagicMomentView()
                    case 2:
                        RecallView()
                    case 3:
                        CreateCardView(
                            firstName: $firstName,
                            lastName: $lastName,
                            role: $role,
                            company: $company,
                            tagline: $tagline,
                            email: $email,
                            focusedField: $focusedField
                        )
                    default:
                        Text("Unknown slide")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Button footer
                VStack(spacing: 12) {
                    PrimaryButton(
                        currentSlide == 3 ? "Enter LinkMe" : (currentSlide == 0 ? "Get started" : (currentSlide == 2 ? "Set up my card" : "Continue")),
                        tone: .ink
                    ) {
                        if currentSlide < 3 {
                            withAnimation {
                                currentSlide += 1
                            }
                        } else {
                            saveUser()
                            onDone()
                        }
                    }
                    .disabled(currentSlide == 3 && !isFormValid)

                    if currentSlide == 0 {
                        Button("I already have a profile") {
                            onDone()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.t700)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, LinkMeLayout.homeInset + 14)
            }
        }
        .onChange(of: currentSlide) { _, slide in
            guard slide == 3 else {
                focusedField = nil
                return
            }

            DispatchQueue.main.async {
                focusedField = .firstName
            }
        }
    }

    private func saveUser() {
        let defaultCard = CardModel(
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            email: email,
            role: role,
            company: company,
            tagline: tagline.isEmpty ? nil : tagline,
            isDefault: true,
            sharedPublicly: false
        )

        let user = UserModel(
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            email: email,
            role: role,
            company: company,
            tagline: tagline.isEmpty ? nil : tagline,
            cards: [defaultCard]
        )
        appState.currentUser = user
    }
}

// MARK: - Slide 1: Welcome
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    Text("Link")
                        .font(.system(size: 30, weight: .semibold, design: .default))
                        .tracking(-0.03)
                        .foregroundColor(LinkMeColors.ink)

                    Text("Me")
                        .font(.system(size: 30, weight: .semibold, design: .default))
                        .tracking(-0.03)
                        .foregroundColor(LinkMeColors.t500)
                }

                Text("The private memory and instinct of a great connector — in your pocket.")
                    .font(.system(size: 16.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 26)
        .padding(.vertical, 40)
    }
}

// MARK: - Wave Animation
struct WaveAnimationView: View {
    @State private var animationPhase: CGFloat = 0
    @State private var timer: Timer?

    let baseHeights: [CGFloat] = [40, 30, 35, 28, 38, 25, 32, 29, 36, 27, 34, 31, 33, 26, 39, 24, 37, 28, 35, 30, 38, 25]

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<22, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: baseHeights[i] * barScale(for: i))
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            animationPhase += 0.016 / 4
            if animationPhase > 1 {
                animationPhase = 0
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }

    private func barScale(for index: Int) -> CGFloat {
        let duration = 0.7 + CGFloat(index % 4) * 0.1
        let delay = CGFloat(index) * 0.05
        let phase = (animationPhase * 4 - delay).truncatingRemainder(dividingBy: duration)
        let progress = phase / duration

        // Wave effect: scale from min to max and back
        let minScale = 0.3
        let maxScale = 1.0
        let scale = minScale + (maxScale - minScale) * (0.5 + 0.5 * sin(progress * .pi * 2 - .pi / 2))

        return max(0.3, min(1.0, scale))
    }
}

// MARK: - Slide 2: Magic Moment
struct MagicMomentView: View {
    @State private var isRecording = false
    @State private var wordCount = 0
    @State private var isDone = false

    let fullNote = "Met Marcus Chen, GP at Meridian — closing fund three, wants to see my metrics."
    let noteWords: [String]

    init() {
        self.noteWords = fullNote.split(separator: " ").map(String.init)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title section
            VStack(spacing: 14) {
                Text("Capture in 10 seconds")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)
                    .tracking(-0.025)

                Text("Speak a note after a meeting. Your iPhone turns it into a person you'll never forget.")
                    .font(.system(size: 15.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 32)

            // Content section
            if isDone {
                // Result card
                VStack(spacing: 14) {
                    Card(padding: 0) {
                        VStack(spacing: 0) {
                            // Header: Avatar + Name/Title + Badge
                            HStack(alignment: .top, spacing: 12) {
                                Avatar(name: "Marcus Chen", size: 44, tone: "teal")

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Marcus Chen")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(LinkMeColors.ink)
                                        .lineLimit(1)

                                    Text("General Partner · Meridian Ventures")
                                        .font(.system(size: 12, design: .default))
                                        .foregroundColor(LinkMeColors.s500)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(spacing: 5) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text("On device")
                                        .font(.system(size: 10, weight: .semibold, design: .default))
                                }
                                .foregroundColor(LinkMeColors.t500)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(LinkMeColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LinkMeColors.t500, lineWidth: 1)
                                )
                            }
                            .padding(16)

                            Divider()

                            // Live context section
                            VStack(alignment: .center, spacing: 4) {
                                Text("LIVE CONTEXT")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

                                Text("Closing fund three. Wants to see your metrics.")
                                    .font(.system(size: 14, design: .default))
                                    .foregroundColor(LinkMeColors.s700)
                                    .lineSpacing(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(EdgeInsets(top: 13, leading: 6, bottom: 16, trailing: 6))
                        }
                    }

                    Text("That's the whole thing.")
                        .font(.system(size: 13.5, weight: .semibold, design: .default))
                        .foregroundColor(LinkMeColors.t700)
                }
                .padding(.horizontal, 22)
            } else {
                // Recording/transcription view
                VStack(spacing: 0) {
                    // Wave or instruction text (conditional)
                    if isRecording {
                        WaveAnimationView()
                            .frame(height: 56)
                    } else {
                        Text("You just met someone. Tap and say one sentence about them.")
                            .font(.system(size: 15, design: .default))
                            .foregroundColor(LinkMeColors.s400)
                            .multilineTextAlignment(.center)
                            .frame(height: 56, alignment: .center)
                    }

                    // Transcription text (only when recording)
                    if isRecording {
                        Text(noteWords.prefix(wordCount).joined(separator: " "))
                            .font(.system(size: 16, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .lineSpacing(2)
                            .frame(minHeight: 48, alignment: .center)
                            .padding(.horizontal, 10)
                    }

                    Spacer()
                        .frame(minHeight: 40)

                    // Mic button
                    RecordButton(isRecording: isRecording) {
                        if !isRecording {
                            isRecording = true
                            wordCount = 0
                            isDone = false
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .onChange(of: isRecording) { oldValue, newValue in
            if newValue {
                // Start word animation (120ms per word)
                Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
                    if wordCount < noteWords.count {
                        wordCount += 1
                    } else {
                        timer.invalidate()
                        // After all words, wait 650ms then show result
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                            isDone = true
                            isRecording = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Slide 3: Recall
struct RecallView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                Text("Recalled — and kept private")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)
                    .tracking(-0.025)

                Text("Right before you meet again, LinkMe briefs you. And it all stays on your iPhone.")
                    .font(.system(size: 15.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        HStack(spacing: 7) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Brief me before 3:00")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .tracking(0.02)
                                .textCase(.uppercase)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                        .background(LinkMeColors.t500)

                        HStack(alignment: .center, spacing: 12) {
                            Avatar(name: "Marcus Chen", size: 44, tone: "teal")

                            BriefingPreviewText()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }

                HStack(alignment: .center, spacing: 10) {
                    // Shield icon in teal box
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LinkMeColors.t700)
                        .frame(width: 34, height: 34)
                        .background(LinkMeColors.t50)
                        .cornerRadius(11)
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .stroke(LinkMeColors.t200, lineWidth: 1)
                        )

                    // Text
                    Text("Capture, briefings and your whole graph stay on this device.")
                        .font(.system(size: 13, design: .default))
                        .foregroundColor(LinkMeColors.s600)
                        .lineSpacing(1)

                    // On this device chip
                    Spacer()
                        .frame(maxWidth: 1)

                    HStack(spacing: 5) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("On this device")
                            .font(.system(size: 10, weight: .semibold, design: .default))
                    }
                    .foregroundColor(LinkMeColors.t700)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(LinkMeColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinkMeColors.t500, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(LinkMeColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(LinkMeColors.s200, lineWidth: 1)
                )
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
    }
}

// MARK: - Slide 4: Create Card
struct CreateCardView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var role: String
    @Binding var company: String
    @Binding var tagline: String
    @Binding var email: String
    @FocusState.Binding var focusedField: OnboardingCardField?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                Text("Create your card")
                    .font(.system(size: 26, weight: .semibold, design: .default))
                    .foregroundColor(LinkMeColors.ink)
                    .tracking(-0.025)

                Text("This is who you are when you meet someone — confirm your details.")
                    .font(.system(size: 15.5, design: .default))
                    .foregroundColor(LinkMeColors.s500)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }

            ScrollView {
                VStack(spacing: 16) {
                    // Live preview
                    Card(padding: 0) {
                        VStack(spacing: 0) {
                            // Gradient header
                            HStack(spacing: 6) {
                                Spacer()
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(0.9)
                                Text("Always current")
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

                            // Content below gradient
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

                    // Form fields
                    VStack(spacing: 11) {
                        // First name & Last name (2 columns)
                        HStack(spacing: 11) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("FIRST NAME")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.s400)
                                    .tracking(0.04)

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
                                    .onSubmit { focusedField = .role }
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

                        // Role & Company (2 columns)
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

                        // Tagline
                        VStack(alignment: .leading, spacing: 5) {
                            Text("ONE LINE ABOUT YOU")
                                .font(.system(size: 10.5, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.s400)
                                .tracking(0.04)

                            TextField("What you're building", text: $tagline)
                                .textFieldStyle(.plain)
                                .font(.system(size: 15, design: .default))
                                .foregroundColor(LinkMeColors.ink)
                                .accentColor(LinkMeColors.t500)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .tagline)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .email }
                                .padding(.horizontal, 13)
                                .padding(.vertical, 12)
                                .frame(height: 46)
                                .background(LinkMeColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .tagline ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                )
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 5) {
                            Text("EMAIL")
                                .font(.system(size: 10.5, weight: .semibold, design: .default))
                                .foregroundColor(LinkMeColors.s400)
                                .tracking(0.04)

                            EmailInput(
                                text: $email,
                                isFocused: Binding(
                                    get: { focusedField == .email },
                                    set: { isFocused in
                                        focusedField = isFocused ? .email : nil
                                    }
                                )
                            )
                                .padding(.horizontal, 13)
                                .frame(height: 46)
                                .background(LinkMeColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .email ? LinkMeColors.t500 : LinkMeColors.s200, lineWidth: 1.5)
                                )
                        }
                    }

                    // Bottom info card
                    HStack(alignment: .center, spacing: 9) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LinkMeColors.t700)

                        Text("This is the card people receive when you share back. You control it — and it stays current automatically.")
                            .font(.system(size: 12.5, design: .default))
                            .foregroundColor(LinkMeColors.s600)
                            .lineSpacing(1.45)

                        Spacer()
                    }
                    .padding(13)
                    .background(LinkMeColors.t50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(LinkMeColors.t200, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 6)
        .padding(.vertical, 14)
    }
}

#Preview {
    OnboardingView(appState: AppState(), onDone: {})
}

import SwiftUI

struct OnboardingView: View {
    var onDone: () -> Void
    @State private var currentSlide = 0

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
                        CreateCardView()
                    default:
                        Text("Unknown slide")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Button footer
                VStack(spacing: 12) {
                    PrimaryButton(
                        currentSlide == 3 ? "Enter LinkMe" : (currentSlide == 0 ? "Get started" : "Continue"),
                        tone: .ink
                    ) {
                        if currentSlide < 3 {
                            withAnimation {
                                currentSlide += 1
                            }
                        } else {
                            onDone()
                        }
                    }

                    if currentSlide == 0 {
                        Button("I already have a profile") {
                            onDone()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinkMeColors.t700)
                    }
                }
                .padding(22)
                .padding(.bottom, LinkMeLayout.homeInset + 14)
            }
        }
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
    @State private var name = ""
    @State private var role = ""
    @State private var company = ""
    @State private var tagline = ""
    @State private var email = ""

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
                            HStack(alignment: .top) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(0.9)

                                Text("Always current")
                                    .font(.system(size: 10.5, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                    .opacity(0.9)

                                Spacer()
                            }
                            .padding(10)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [LinkMeColors.t500, LinkMeColors.t700]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))

                            VStack(alignment: .leading, spacing: 8) {
                                Avatar(name: name.isEmpty ? "You" : name, size: 56)
                                    .padding(.top, -24)

                                Text(name.isEmpty ? "Your name" : name)
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(LinkMeColors.ink)

                                Text("\(role.isEmpty ? "Role" : role) · \(company.isEmpty ? "Company" : company)")
                                    .font(.system(size: 13, design: .default))
                                    .foregroundColor(LinkMeColors.s500)

                                if !tagline.isEmpty {
                                    Text(tagline)
                                        .font(.system(size: 13, design: .default))
                                        .foregroundColor(LinkMeColors.s600)
                                        .lineLimit(2)
                                }
                            }
                            .padding(16)
                        }
                    }

                    // Form fields
                    VStack(spacing: 11) {
                        TextField("Your name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .padding(4)

                        HStack(spacing: 11) {
                            TextField("Founder & CEO", text: $role)
                                .textFieldStyle(.roundedBorder)
                            TextField("Company", text: $company)
                                .textFieldStyle(.roundedBorder)
                        }

                        TextField("What you're building", text: $tagline)
                            .textFieldStyle(.roundedBorder)
                            .padding(4)

                        TextField("you@company.com", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .padding(4)
                    }
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
    OnboardingView(onDone: {})
}

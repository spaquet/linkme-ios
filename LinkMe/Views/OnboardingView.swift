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

// MARK: - Slide 2: Magic Moment
struct MagicMomentView: View {
    @State private var isRecording = false
    @State private var wordCount = 0

    var body: some View {
        VStack(spacing: 24) {
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

            VStack(spacing: 20) {
                // Wave animation placeholder
                HStack(spacing: 4) {
                    ForEach(0..<12, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 4, height: CGFloat([40, 30, 35, 28, 38, 25, 32, 29, 36, 27, 34, 31][i]))
                            .opacity(isRecording ? 1 : 0.25)
                    }
                }
                .frame(height: 56)
                .padding(.vertical, 10)

                Text(isRecording ? "Met Marcus Chen, GP at Meridian..." : "Tap to record")
                    .font(.system(size: 16, design: .default))
                    .foregroundColor(LinkMeColors.s600)
                    .frame(height: 48)

                Button(action: {
                    withAnimation { isRecording.toggle() }
                }) {
                    ZStack {
                        if isRecording {
                            Circle()
                                .fill(LinkMeColors.ink)
                        } else {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                                    startPoint: .init(x: 0, y: 0),
                                    endPoint: .init(x: 0.5, y: 0.5)
                                ))
                        }

                        if !isRecording {
                            Circle()
                                .stroke(LinkMeColors.t400, lineWidth: 2)
                                .padding(5)
                                .opacity(0.5)
                                .scaleEffect(1.4)
                        }

                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 76, height: 76)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
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

                        HStack(spacing: 12) {
                            Avatar(name: "Marcus Chen", size: 44)

                            Text("Lead with the **fund close**. He owes you the memo; you offered an intro.")
                                .font(.system(size: 14, design: .default))
                                .foregroundColor(LinkMeColors.s700)
                                .lineLimit(2)
                        }
                        .padding(16)
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(LinkMeColors.t700)
                        .frame(width: 34, height: 34, alignment: .center)
                        .background(LinkMeColors.t50)
                        .cornerRadius(11)

                    Text("Capture, briefings and your whole graph stay on this device.")
                        .font(.system(size: 13, design: .default))
                        .foregroundColor(LinkMeColors.s600)
                        .lineLimit(2)

                    OnDeviceChip()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
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

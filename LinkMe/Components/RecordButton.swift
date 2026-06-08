import SwiftUI

struct RecordButton: View {
    @State private var isPulsing = false
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            // Pulse ring (idle only)
            if !isRecording {
                Circle()
                    .stroke(LinkMeColors.t400, lineWidth: 2)
                    .frame(width: 86, height: 86)
                    .scaleEffect(isPulsing ? 1.9 : 1.0)
                    .opacity(isPulsing ? 0 : 0.45)
                    .animation(
                        Animation.easeOut(duration: 1.8)
                            .repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            }

            // Main button
            Button(action: action) {
                ZStack {
                    // Background circle
                    if isRecording {
                        Circle()
                            .fill(LinkMeColors.ink)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [LinkMeColors.t400, LinkMeColors.t600]),
                                    startPoint: .init(x: 0, y: 0),
                                    endPoint: .init(x: 0.5, y: 0.5)
                                )
                            )
                    }

                    // White border
                    Circle()
                        .stroke(LinkMeColors.surface, lineWidth: 5)

                    // Icon (mic or stop)
                    if isRecording {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(LinkMeColors.surface)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(LinkMeColors.surface)
                    }
                }
                .frame(width: 76, height: 76)
                .shadow(
                    color: isRecording
                        ? LinkMeColors.ink.opacity(0.22)
                        : LinkMeColors.t500.opacity(0.45),
                    radius: isRecording ? 12 : 10,
                    x: 0,
                    y: isRecording ? 12 : 10
                )
            }
        }
        .onAppear {
            if !isRecording {
                isPulsing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        RecordButton(isRecording: false) {}
        RecordButton(isRecording: true) {}
    }
    .padding()
    .background(LinkMeColors.canvas)
}

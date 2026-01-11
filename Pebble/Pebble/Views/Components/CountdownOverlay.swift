import SwiftUI

/// Full-screen countdown overlay for emergency unlock
struct CountdownOverlay: View {

    let remaining: TimeInterval
    let onCancel: () -> Void

    private var progress: Double {
        remaining / Constants.emergencyCountdownDuration
    }

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Emergency Unlock")
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Countdown circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remaining)

                    Text("\(Int(remaining))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Text("Keep this screen open")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

/// Confirmation modal before starting emergency unlock
struct EmergencyConfirmationView: View {

    let usesRemaining: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Emergency Unlock")
                .font(.title2.bold())

            VStack(spacing: 8) {
                Text("This will unlock your apps without a Pebble.")
                    .multilineTextAlignment(.center)

                Text("You have \(usesRemaining) emergency unlock\(usesRemaining == 1 ? "" : "s") remaining.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("A \(Int(Constants.emergencyCountdownDuration))-second countdown will begin.")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Button("Start Countdown") {
                    onConfirm()
                }
                .buttonStyle(PebbleButtonStyle(backgroundColor: .orange))

                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding(32)
    }
}

// MARK: - Previews

#Preview("Countdown") {
    CountdownOverlay(remaining: 10, onCancel: {})
}

#Preview("Confirmation") {
    EmergencyConfirmationView(
        usesRemaining: 3,
        onConfirm: {},
        onCancel: {}
    )
}

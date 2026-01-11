import SwiftUI

/// Dedicated view for managing emergency override settings
struct EmergencyOverrideInfoView: View {

    let usesRemaining: Int
    let totalUses: Int

    private var usesUsed: Int {
        totalUses - usesRemaining
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sos")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                Text("Emergency Unlock")
                    .font(.title2.bold())
            }

            // Info card
            VStack(alignment: .leading, spacing: 16) {
                infoRow(
                    icon: "number.circle",
                    title: "Uses Remaining",
                    value: "\(usesRemaining) of \(totalUses)"
                )

                infoRow(
                    icon: "timer",
                    title: "Countdown Duration",
                    value: "\(Int(Constants.emergencyCountdownDuration)) seconds"
                )

                infoRow(
                    icon: "exclamationmark.triangle",
                    title: "Purpose",
                    value: "For when you lose your Pebble"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Warning
            Text("Emergency unlocks are limited and cannot be restored. Use only when absolutely necessary.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Emergency Unlock")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        EmergencyOverrideInfoView(
            usesRemaining: 3,
            totalUses: Constants.emergencyOverrideLimit
        )
    }
}

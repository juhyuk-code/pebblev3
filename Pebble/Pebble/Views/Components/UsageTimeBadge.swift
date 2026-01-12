import SwiftUI

/// Pill-shaped badge showing usage time today
struct UsageTimeBadge: View {

    let hours: Int
    let minutes: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("\(hours)h \(minutes)m")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text("today")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Previews

#Preview {
    UsageTimeBadge(hours: 0, minutes: 0)
}

#Preview("With Time") {
    UsageTimeBadge(hours: 2, minutes: 34)
}

import SwiftUI

/// Pill-shaped badge showing pebbled time
struct UsageTimeBadge: View {

    /// The date when pebbling started (nil if not pebbled)
    let startDate: Date?

    /// Timer to update the display every second
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            Text(formattedTime)
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
        .onReceive(timer) { _ in
            now = Date()
        }
    }

    private var formattedTime: String {
        guard let start = startDate else {
            return "0h 0m"
        }

        let elapsed = now.timeIntervalSince(start)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60

        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Previews

#Preview("Not Pebbled") {
    UsageTimeBadge(startDate: nil)
}

#Preview("Just Started") {
    UsageTimeBadge(startDate: Date())
}

#Preview("1 Hour Ago") {
    UsageTimeBadge(startDate: Date().addingTimeInterval(-3600))
}

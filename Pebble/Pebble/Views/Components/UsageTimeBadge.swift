import SwiftUI

/// Pill-shaped badge showing pebbled time
struct UsageTimeBadge: View {

    /// The date when pebbling started (nil if not pebbled)
    let startDate: Date?
    var isLocked: Bool = false

    /// Timer to update the display every second
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var primaryColor: Color {
        isLocked ? .white : .primary
    }

    private var secondaryColor: Color {
        isLocked ? Color(white: 0.7) : .secondary
    }

    private var backgroundColor: Color {
        isLocked ? Color(white: 0.15) : Color(.systemGray6)
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(formattedTime)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(primaryColor)

            Text("today")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(secondaryColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(backgroundColor)
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

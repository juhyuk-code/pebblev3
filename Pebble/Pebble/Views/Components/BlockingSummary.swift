import SwiftUI

/// Shows summary of blocked apps and websites
struct BlockingSummary: View {

    let appCount: Int
    let websiteCount: Int
    var isLocked: Bool = false

    private var textColor: Color {
        isLocked ? Color(white: 0.7) : .secondary
    }

    var body: some View {
        Text(summaryText)
            .font(.system(size: 14))
            .foregroundColor(textColor)
    }

    private var summaryText: String {
        var parts: [String] = []

        if appCount > 0 {
            parts.append("\(appCount) app\(appCount == 1 ? "" : "s")")
        }

        if websiteCount > 0 {
            parts.append("\(websiteCount) website\(websiteCount == 1 ? "" : "s")")
        }

        if parts.isEmpty {
            return "No apps blocked"
        }

        return "Blocking " + parts.joined(separator: ", ")
    }
}

// MARK: - Previews

#Preview {
    BlockingSummary(appCount: 29, websiteCount: 3)
}

#Preview("Apps Only") {
    BlockingSummary(appCount: 5, websiteCount: 0)
}

#Preview("None") {
    BlockingSummary(appCount: 0, websiteCount: 0)
}

import Foundation
import FamilyControls

/// Represents a blocking mode with a set of apps/websites to block
struct BlockingMode: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var selection: FamilyActivitySelection
    var isDefault: Bool

    /// Create a new custom mode
    init(id: UUID = UUID(), name: String, selection: FamilyActivitySelection = FamilyActivitySelection(), isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.selection = selection
        self.isDefault = isDefault
    }

    /// Number of apps in this mode
    var appCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }

    /// Number of websites in this mode
    var websiteCount: Int {
        selection.webDomainTokens.count
    }

    /// Summary text like "29 apps, 3 websites"
    var summaryText: String {
        var parts: [String] = []

        if appCount > 0 {
            parts.append("\(appCount) app\(appCount == 1 ? "" : "s")")
        }

        if websiteCount > 0 {
            parts.append("\(websiteCount) website\(websiteCount == 1 ? "" : "s")")
        }

        if parts.isEmpty {
            return "No apps selected"
        }

        return parts.joined(separator: ", ")
    }

    // MARK: - Default Modes

    /// The default "Mindful Mode" that comes with the app
    static var mindfulMode: BlockingMode {
        BlockingMode(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Mindful Mode",
            selection: FamilyActivitySelection(),
            isDefault: true
        )
    }

    // MARK: - Equatable

    static func == (lhs: BlockingMode, rhs: BlockingMode) -> Bool {
        lhs.id == rhs.id
    }
}

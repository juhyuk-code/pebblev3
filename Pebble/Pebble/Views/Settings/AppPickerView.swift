import SwiftUI
import FamilyControls

/// Wrapper around FamilyActivityPicker for selecting apps to block
struct AppPickerView: View {

    @Binding var selection: FamilyActivitySelection
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Select Apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave()
                            dismiss()
                        }
                    }
                }
        }
    }
}

/// Summary view showing selected apps count
struct AppSelectionSummary: View {

    let selection: FamilyActivitySelection

    private var appCount: Int {
        selection.applicationTokens.count
    }

    private var categoryCount: Int {
        selection.categoryTokens.count
    }

    private var totalCount: Int {
        appCount + categoryCount
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Apps to Block")
                    .font(.headline)

                if totalCount == 0 {
                    Text("No apps selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var summaryText: String {
        var parts: [String] = []

        if appCount > 0 {
            parts.append("\(appCount) app\(appCount == 1 ? "" : "s")")
        }

        if categoryCount > 0 {
            parts.append("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")")
        }

        return parts.joined(separator: ", ")
    }
}

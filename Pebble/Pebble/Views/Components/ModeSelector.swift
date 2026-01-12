import SwiftUI

/// Dropdown selector for blocking modes
struct ModeSelector: View {

    @Binding var selectedMode: BlockingMode
    @State private var showingPicker = false

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack(spacing: 6) {
                Text("Mode:")
                    .foregroundColor(.secondary)

                Text(selectedMode.displayName)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 16))
        }
        .confirmationDialog("Select Mode", isPresented: $showingPicker) {
            ForEach(BlockingMode.allCases, id: \.self) { mode in
                Button(mode.displayName) {
                    selectedMode = mode
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

/// Available blocking modes
enum BlockingMode: String, CaseIterable, Codable {
    case mindful = "mindful"
    case focus = "focus"
    case sleep = "sleep"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .mindful: return "Mindful Mode"
        case .focus: return "Focus Mode"
        case .sleep: return "Sleep Mode"
        case .custom: return "Custom Mode"
        }
    }
}

// MARK: - Previews

#Preview {
    ModeSelector(selectedMode: .constant(.mindful))
}

import SwiftUI

/// Dropdown selector for blocking modes - tapping opens the mode selection sheet
struct ModeSelector: View {

    @ObservedObject var modeManager: ModeManager
    @Binding var showingSheet: Bool

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack(spacing: 6) {
                Text("Mode:")
                    .foregroundColor(.secondary)

                Text(modeManager.selectedMode?.name ?? "Select Mode")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 16))
        }
    }
}

// MARK: - Previews

#Preview {
    ModeSelector(
        modeManager: .preview,
        showingSheet: .constant(false)
    )
}

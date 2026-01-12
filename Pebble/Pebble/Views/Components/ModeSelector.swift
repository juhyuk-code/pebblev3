import SwiftUI

/// Dropdown selector for blocking modes - tapping opens the mode selection sheet
struct ModeSelector: View {

    @ObservedObject var modeManager: ModeManager
    @Binding var showingSheet: Bool
    var isLocked: Bool = false

    private var labelColor: Color {
        isLocked ? Color(white: 0.7) : .secondary
    }

    private var valueColor: Color {
        isLocked ? .white : .primary
    }

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack(spacing: 6) {
                Text("Mode:")
                    .foregroundColor(labelColor)

                Text(modeManager.selectedMode?.name ?? "Select Mode")
                    .fontWeight(.medium)
                    .foregroundColor(valueColor)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(labelColor)
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

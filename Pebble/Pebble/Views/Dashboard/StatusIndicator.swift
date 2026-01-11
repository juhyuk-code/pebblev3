import SwiftUI

/// Displays the current lock state with icon and text
struct StatusIndicator: View {

    let state: LockState

    private var stateColor: Color {
        Color.forState(state)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Lock icon
            Image(systemName: state.iconName)
                .font(.system(size: 64))
                .foregroundColor(stateColor)

            // Status text
            Text(state.displayText)
                .font(.title.bold())
                .foregroundColor(stateColor)

            // Subtitle
            Text(state == .locked ? "Tap Pebble to unlock" : "Your apps are accessible")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .animation(.easeInOut(duration: 0.3), value: state)
    }
}

// MARK: - Previews

#Preview("Free State") {
    StatusIndicator(state: .free)
}

#Preview("Locked State") {
    StatusIndicator(state: .locked)
}

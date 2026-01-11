import SwiftUI

/// Primary action button style for Pebble
struct PebbleButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let foregroundColor: Color

    init(
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(foregroundColor)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(backgroundColor)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Large circular scan button
struct ScanButton: View {

    let state: LockState
    let isScanning: Bool
    let action: () -> Void

    private var backgroundColor: Color {
        isScanning ? .gray : Color.forState(state)
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 200, height: 200)
                    .shadow(color: backgroundColor.opacity(0.4), radius: 20, x: 0, y: 10)

                VStack(spacing: 12) {
                    if isScanning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                    }

                    Text(isScanning ? "Scanning..." : "SCAN")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isScanning)
        .scaleEffect(isScanning ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isScanning)
    }
}

/// Secondary button style
struct SecondaryButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Scan Button - Free") {
    ScanButton(state: .free, isScanning: false, action: {})
        .padding()
}

#Preview("Scan Button - Locked") {
    ScanButton(state: .locked, isScanning: false, action: {})
        .padding()
}

#Preview("Scan Button - Scanning") {
    ScanButton(state: .free, isScanning: true, action: {})
        .padding()
}

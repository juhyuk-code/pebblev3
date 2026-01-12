import SwiftUI

/// Displays the Pebble device image
struct PebbleDeviceView: View {

    var isScanning: Bool = false
    var isLocked: Bool = false

    private let imageSize: CGFloat = 220

    var body: some View {
        Image("PebbleDevice")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize)
            .opacity(isScanning ? 0.7 : 1.0)
            .shadow(
                color: isLocked ? Color.white.opacity(0.6) : Color.clear,
                radius: isLocked ? 20 : 0
            )
            .shadow(
                color: isLocked ? Color.white.opacity(0.4) : Color.clear,
                radius: isLocked ? 40 : 0
            )
            .shadow(
                color: isLocked ? Color.white.opacity(0.2) : Color.clear,
                radius: isLocked ? 80 : 0
            )
            .animation(.easeInOut(duration: 0.3), value: isScanning)
            .animation(.easeInOut(duration: 0.3), value: isLocked)
    }
}

// MARK: - Previews

#Preview {
    PebbleDeviceView()
        .padding()
}

#Preview("Locked with Glow") {
    ZStack {
        Color.black.ignoresSafeArea()
        PebbleDeviceView(isLocked: true)
    }
}

#Preview("Scanning") {
    PebbleDeviceView(isScanning: true)
        .padding()
}

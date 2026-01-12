import SwiftUI

/// Displays the Pebble device image
struct PebbleDeviceView: View {

    var isScanning: Bool = false

    private let imageSize: CGFloat = 220

    var body: some View {
        Image("PebbleDevice")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize)
            .opacity(isScanning ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isScanning)
    }
}

// MARK: - Previews

#Preview {
    PebbleDeviceView()
        .padding()
}

#Preview("Scanning") {
    PebbleDeviceView(isScanning: true)
        .padding()
}

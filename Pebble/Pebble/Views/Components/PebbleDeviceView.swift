import SwiftUI

/// Displays the Pebble device image with scanning bracket corners
struct PebbleDeviceView: View {

    var isScanning: Bool = false

    private let bracketSize: CGFloat = 40
    private let bracketThickness: CGFloat = 3
    private let imageSize: CGFloat = 180
    private let bracketPadding: CGFloat = 20

    var body: some View {
        ZStack {
            // Pebble device image
            Image("PebbleDevice")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)

            // Scanning brackets
            scanningBrackets
                .opacity(isScanning ? 1 : 0.6)
                .animation(.easeInOut(duration: 0.3), value: isScanning)
        }
        .frame(width: imageSize + bracketPadding * 2, height: imageSize + bracketPadding * 2)
    }

    private var scanningBrackets: some View {
        let totalSize = imageSize + bracketPadding

        return ZStack {
            // Top-left bracket
            BracketCorner(rotation: 0)
                .position(x: bracketPadding, y: bracketPadding)

            // Top-right bracket
            BracketCorner(rotation: 90)
                .position(x: totalSize, y: bracketPadding)

            // Bottom-right bracket
            BracketCorner(rotation: 180)
                .position(x: totalSize, y: totalSize)

            // Bottom-left bracket
            BracketCorner(rotation: 270)
                .position(x: bracketPadding, y: totalSize)
        }
        .frame(width: totalSize + bracketPadding, height: totalSize + bracketPadding)
    }
}

/// Single corner bracket shape
struct BracketCorner: View {

    let rotation: Double
    private let size: CGFloat = 30
    private let thickness: CGFloat = 3

    var body: some View {
        Path { path in
            // Vertical line
            path.move(to: CGPoint(x: 0, y: size))
            path.addLine(to: CGPoint(x: 0, y: 0))
            // Horizontal line
            path.addLine(to: CGPoint(x: size, y: 0))
        }
        .stroke(Color(.systemGray3), style: StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
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

import SwiftUI

/// Activity tab - usage statistics
struct ActivityView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)

                Text("Coming Soon")
                    .font(.title2.bold())

                Text("Track your screen time\nand see your progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("Activity")
        }
    }
}

// MARK: - Previews

#Preview {
    ActivityView()
}

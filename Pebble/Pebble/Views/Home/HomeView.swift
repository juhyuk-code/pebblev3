import SwiftUI

/// Main home screen (Pebble tab) - mimics Brick app layout
struct HomeView: View {

    @ObservedObject var viewModel: DashboardViewModel
    @State private var selectedMode: BlockingMode = .mindful

    // Background color matching Brick's warm gray
    private let backgroundColor = Color(red: 0.93, green: 0.91, blue: 0.89)

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Usage time badge at top
                UsageTimeBadge(hours: 0, minutes: 0)
                    .padding(.top, 40)

                Spacer()

                // Pebble device with scan brackets
                PebbleDeviceView(isScanning: viewModel.isScanning)

                // Mode selector
                ModeSelector(selectedMode: $selectedMode)
                    .padding(.top, 24)

                // Blocking summary
                BlockingSummary(
                    appCount: viewModel.blockedAppCount,
                    websiteCount: viewModel.blockedWebsiteCount
                )
                .padding(.top, 8)

                Spacer()

                // Main action button
                Button {
                    Task {
                        await viewModel.scanPebble()
                    }
                } label: {
                    Text("Pebble device")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray5))
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .disabled(viewModel.isScanning)
            }

            // Emergency overlay (if needed)
            emergencyOverlay
        }
        .alert("Scan Result", isPresented: $viewModel.showingScanResult) {
            Button("OK") {
                viewModel.dismissScanResult()
            }
        } message: {
            Text(viewModel.scanResult?.message ?? "")
        }
    }

    @ViewBuilder
    private var emergencyOverlay: some View {
        switch viewModel.emergencyUnlockState {
        case .confirming:
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.cancelEmergencyOverride()
                }

            EmergencyConfirmationView(
                usesRemaining: viewModel.emergencyUsesRemaining,
                onConfirm: {
                    viewModel.confirmEmergencyOverride()
                },
                onCancel: {
                    viewModel.cancelEmergencyOverride()
                }
            )
            .transition(.scale.combined(with: .opacity))

        case .counting(let remaining):
            CountdownOverlay(remaining: remaining) {
                viewModel.cancelEmergencyOverride()
            }
            .transition(.opacity)

        case .unlocking:
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                Text("Unlocking...")
                    .foregroundColor(.white)
                    .padding(.top)
            }

        case .idle:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    HomeView(viewModel: .preview)
}

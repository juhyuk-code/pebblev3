import SwiftUI

/// Main home screen (Pebble tab) - mimics Brick app layout
struct HomeView: View {

    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var modeManager: ModeManager
    @State private var showingModeSheet: Bool = false

    // Background colors
    private let freeBackgroundColor = Color(red: 0.93, green: 0.91, blue: 0.89)
    private let lockedBackgroundColor = Color.black

    private var backgroundColor: Color {
        viewModel.isLocked ? lockedBackgroundColor : freeBackgroundColor
    }

    private var buttonBackgroundColor: Color {
        viewModel.isLocked ? Color(white: 0.15) : Color(.systemGray5)
    }

    private var buttonTextColor: Color {
        viewModel.isLocked ? .white : .primary
    }

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLocked)

            VStack(spacing: 0) {
                // Usage time badge at top
                UsageTimeBadge(startDate: viewModel.lockedAt, isLocked: viewModel.isLocked)
                    .padding(.top, 40)

                Spacer()

                // Pebble device image
                PebbleDeviceView(isScanning: viewModel.isScanning, isLocked: viewModel.isLocked)

                // Mode selector
                ModeSelector(modeManager: modeManager, showingSheet: $showingModeSheet, isLocked: viewModel.isLocked)
                    .padding(.top, 24)

                // Blocking summary
                BlockingSummary(
                    appCount: modeManager.selectedMode?.appCount ?? 0,
                    websiteCount: modeManager.selectedMode?.websiteCount ?? 0,
                    isLocked: viewModel.isLocked
                )
                .padding(.top, 8)

                Spacer()

                // Main action button
                Button {
                    Task {
                        await viewModel.scanPebble()
                    }
                } label: {
                    Text(viewModel.isLocked ? "Unpebble device" : "Pebble device")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(buttonTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(buttonBackgroundColor)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .disabled(viewModel.isScanning)
            }

            // Emergency overlay (if needed)
            emergencyOverlay
        }
        .sheet(isPresented: $showingModeSheet) {
            ModeSelectionSheet(modeManager: modeManager, isPresented: $showingModeSheet)
                .presentationDetents([.medium, .large])
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

#Preview("Free") {
    HomeView(viewModel: .preview, modeManager: .preview)
}

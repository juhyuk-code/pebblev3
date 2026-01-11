import SwiftUI

/// Main dashboard screen
struct DashboardView: View {

    @StateObject var viewModel: DashboardViewModel
    var settingsViewModel: SettingsViewModel?
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.pebbleBackground
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Status indicator
                    StatusIndicator(state: viewModel.lockState)

                    // Scan button
                    ScanButton(
                        state: viewModel.lockState,
                        isScanning: viewModel.isScanning
                    ) {
                        Task {
                            await viewModel.scanPebble()
                        }
                    }

                    Spacer()

                    // Bottom actions
                    VStack(spacing: 16) {
                        // Settings button (disabled when locked)
                        Button {
                            showingSettings = true
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("Settings")
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(viewModel.isLocked)
                        .opacity(viewModel.isLocked ? 0.5 : 1)

                        // Emergency unlock button
                        Button {
                            viewModel.startEmergencyOverride()
                        } label: {
                            HStack {
                                Image(systemName: "sos")
                                Text("Emergency Unlock")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .disabled(!viewModel.canUseEmergencyOverride)
                        .opacity(viewModel.canUseEmergencyOverride ? 1 : 0.5)
                    }
                    .padding(.bottom, 32)
                }
                .padding()

                // Emergency overlay
                emergencyOverlay
            }
            .navigationTitle("Pebble")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSettings) {
                if let settingsVM = settingsViewModel {
                    SettingsView(viewModel: settingsVM)
                } else {
                    SettingsView(viewModel: .preview)
                }
            }
            .alert("Scan Result", isPresented: $viewModel.showingScanResult) {
                Button("OK") {
                    viewModel.dismissScanResult()
                }
            } message: {
                Text(viewModel.scanResult?.message ?? "")
            }
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

#Preview("Free State") {
    DashboardView(viewModel: .preview)
}

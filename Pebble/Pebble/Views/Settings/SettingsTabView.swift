import SwiftUI

/// Settings tab wrapper (without modal presentation)
struct SettingsTabView: View {

    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                // Authorization section
                authorizationSection

                // App selection section
                if viewModel.isAuthorized {
                    appSelectionSection
                }

                // Emergency override section
                emergencySection

                // Debug section (only in debug builds)
                #if DEBUG
                debugSection
                #endif

                // About section
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showingAppPicker) {
                AppPickerView(selection: $viewModel.appSelection) {
                    viewModel.saveAppSelection()
                }
            }
        }
    }

    // MARK: - Sections

    private var authorizationSection: some View {
        Section {
            if viewModel.isAuthorized {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Screen Time Access Granted")
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Screen Time Access Required")
                        .font(.headline)

                    Text("Pebble needs Screen Time access to block apps.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let error = viewModel.authorizationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button {
                        Task {
                            await viewModel.requestAuthorization()
                        }
                    } label: {
                        if viewModel.isRequestingAuthorization {
                            ProgressView()
                        } else {
                            Text("Grant Access")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isRequestingAuthorization)
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("Authorization")
        }
    }

    private var appSelectionSection: some View {
        Section {
            Button {
                viewModel.showingAppPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blocked Apps")
                            .foregroundColor(.primary)
                        Text("\(viewModel.selectedAppCount) selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Block List")
        } footer: {
            Text("Select the apps you want to block when Pebble is locked.")
        }
    }

    private var emergencySection: some View {
        Section {
            NavigationLink {
                EmergencyOverrideInfoView(
                    usesRemaining: 5, // TODO: Get from state manager
                    totalUses: Constants.emergencyOverrideLimit
                )
            } label: {
                HStack {
                    Image(systemName: "sos")
                        .foregroundColor(.orange)
                    Text("Emergency Unlock")
                }
            }
        } header: {
            Text("Safety")
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section {
            Toggle("Use Mock NFC Scanner", isOn: Binding(
                get: { viewModel.debugUseMockNFC },
                set: { _ in viewModel.toggleDebugMockNFC() }
            ))
        } header: {
            Text("Debug")
        } footer: {
            Text("Enable this to test NFC flows in the simulator.")
        }
    }
    #endif

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Constants.App.version)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}

// MARK: - Previews

#Preview {
    SettingsTabView(viewModel: .preview)
}

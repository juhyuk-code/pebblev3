import SwiftUI
import FamilyControls

/// Settings and configuration screen
struct SettingsView: View {

    @StateObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Authorization section
                authorizationSection

                // App selection section
                if viewModel.isAuthorized {
                    appSelectionSection
                }

                // Debug section (only in debug builds)
                #if DEBUG
                debugSection
                #endif

                // About section
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
                AppSelectionSummary(selection: viewModel.appSelection)
            }
            .foregroundColor(.primary)
        } header: {
            Text("Blocked Apps")
        } footer: {
            Text("Select the apps you want to block when Pebble is locked.")
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
            Text("Enable this to test NFC flows in the simulator or without a physical Pebble tag.")
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

            HStack {
                Text("Emergency Unlocks")
                Spacer()
                Text("Configured in app")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}

// MARK: - Previews

#Preview {
    SettingsView(viewModel: .preview)
}

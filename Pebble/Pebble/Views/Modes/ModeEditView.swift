import SwiftUI
import FamilyControls

/// View for editing or creating a blocking mode
struct ModeEditView: View {

    @ObservedObject var modeManager: ModeManager
    @State var mode: BlockingMode
    let isNewMode: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var showingAppPicker: Bool = false
    @State private var showingDeleteConfirmation: Bool = false

    // Background color matching the app
    private let backgroundColor = Color(red: 0.93, green: 0.91, blue: 0.89)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Mode name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mode name")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        TextField("Enter mode name", text: $mode.name)
                            .font(.system(size: 17))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .padding(.horizontal, 20)

                    // App selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Blocked apps")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        Button {
                            showingAppPicker = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Select apps to block")
                                        .font(.system(size: 17))
                                        .foregroundColor(.primary)

                                    Text(mode.summaryText)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Delete button (only for non-default modes)
                    if !isNewMode && !mode.isDefault {
                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            Text("Delete Mode")
                                .font(.system(size: 17))
                                .foregroundColor(.red)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 24)
            }
            .navigationTitle(isNewMode ? "Create Mode" : "Edit Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMode()
                    }
                    .disabled(mode.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .familyActivityPicker(
                isPresented: $showingAppPicker,
                selection: $mode.selection
            )
            .alert("Delete Mode", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modeManager.deleteMode(mode)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \"\(mode.name)\"? This cannot be undone.")
            }
        }
    }

    private func saveMode() {
        // Trim whitespace from name
        mode.name = mode.name.trimmingCharacters(in: .whitespaces)

        if isNewMode {
            let newMode = modeManager.createMode(name: mode.name, selection: mode.selection)
            modeManager.selectMode(newMode)
        } else {
            modeManager.updateMode(mode)
        }

        dismiss()
    }
}

// MARK: - Previews

#Preview("New Mode") {
    ModeEditView(
        modeManager: .preview,
        mode: BlockingMode(name: ""),
        isNewMode: true
    )
}

#Preview("Edit Mode") {
    ModeEditView(
        modeManager: .preview,
        mode: .mindfulMode,
        isNewMode: false
    )
}

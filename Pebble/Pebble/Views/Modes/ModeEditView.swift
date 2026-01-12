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

    /// Check if there are any blocked items
    private var hasBlockedItems: Bool {
        !mode.selection.applicationTokens.isEmpty ||
        !mode.selection.categoryTokens.isEmpty ||
        !mode.selection.webDomainTokens.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Blocked apps")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            // Select apps button
                            Button {
                                showingAppPicker = true
                            } label: {
                                HStack {
                                    Text("Select apps to block")
                                        .font(.system(size: 17))
                                        .foregroundColor(.primary)

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

                            // Summary of blocked items
                            if hasBlockedItems {
                                VStack(spacing: 0) {
                                    // Apps count
                                    if !mode.selection.applicationTokens.isEmpty {
                                        HStack(spacing: 12) {
                                            Image(systemName: "app.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                                .frame(width: 40, height: 40)

                                            Text("\(mode.selection.applicationTokens.count) app\(mode.selection.applicationTokens.count == 1 ? "" : "s") blocked")
                                                .font(.system(size: 16))
                                                .foregroundColor(.primary)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)

                                        if !mode.selection.categoryTokens.isEmpty || !mode.selection.webDomainTokens.isEmpty {
                                            Divider()
                                                .padding(.leading, 68)
                                        }
                                    }

                                    // Categories count
                                    if !mode.selection.categoryTokens.isEmpty {
                                        HStack(spacing: 12) {
                                            Image(systemName: "folder.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.orange)
                                                .frame(width: 40, height: 40)

                                            Text("\(mode.selection.categoryTokens.count) categor\(mode.selection.categoryTokens.count == 1 ? "y" : "ies") blocked")
                                                .font(.system(size: 16))
                                                .foregroundColor(.primary)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)

                                        if !mode.selection.webDomainTokens.isEmpty {
                                            Divider()
                                                .padding(.leading, 68)
                                        }
                                    }

                                    // Websites count
                                    if !mode.selection.webDomainTokens.isEmpty {
                                        HStack(spacing: 12) {
                                            Image(systemName: "globe")
                                                .font(.system(size: 24))
                                                .foregroundColor(.green)
                                                .frame(width: 40, height: 40)

                                            Text("\(mode.selection.webDomainTokens.count) website\(mode.selection.webDomainTokens.count == 1 ? "" : "s") blocked")
                                                .font(.system(size: 16))
                                                .foregroundColor(.primary)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            } else {
                                Text("No apps selected")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Delete button (only for non-default modes)
                        if !isNewMode && !mode.isDefault {
                            Button {
                                showingDeleteConfirmation = true
                            } label: {
                                Text("Delete Mode")
                                    .font(.system(size: 17))
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 20)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
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

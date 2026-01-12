import SwiftUI

/// Bottom sheet for selecting blocking modes
struct ModeSelectionSheet: View {

    @ObservedObject var modeManager: ModeManager
    @Binding var isPresented: Bool
    var isLocked: Bool = false
    @State private var editingMode: BlockingMode?
    @State private var isCreatingMode: Bool = false

    // Background color matching the app
    private let backgroundColor = Color(red: 0.93, green: 0.91, blue: 0.89)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                // Mode list
                VStack(spacing: 12) {
                    ForEach(modeManager.modes) { mode in
                        ModeRow(
                            mode: mode,
                            isSelected: mode.id == modeManager.selectedModeId,
                            isLocked: isLocked,
                            onSelect: {
                                if !isLocked {
                                    modeManager.selectMode(mode)
                                }
                            },
                            onEdit: {
                                editingMode = mode
                            }
                        )
                    }

                    // Create mode row (hidden when locked)
                    if !isLocked {
                        CreateModeRow {
                            isCreatingMode = true
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Done button
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(item: $editingMode) { mode in
            ModeEditView(
                modeManager: modeManager,
                mode: mode,
                isNewMode: false,
                isLocked: isLocked
            )
        }
        .sheet(isPresented: $isCreatingMode) {
            ModeEditView(
                modeManager: modeManager,
                mode: BlockingMode(name: ""),
                isNewMode: true,
                isLocked: false
            )
        }
    }

    private var header: some View {
        HStack {
            Text("Select mode")
                .font(.system(size: 20, weight: .semibold))

            Spacer()

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color(.systemGray5)))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Mode Row

struct ModeRow: View {

    let mode: BlockingMode
    let isSelected: Bool
    var isLocked: Bool = false
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button {
            if !isLocked {
                onSelect()
            }
        } label: {
            HStack {
                // Selection indicator when locked
                if isLocked && isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }

                Text(mode.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Text(isLocked ? "View" : "Edit")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
        .opacity(isLocked && !isSelected ? 0.5 : 1.0)
    }
}

// MARK: - Create Mode Row

struct CreateModeRow: View {

    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text("Create mode")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Unlocked") {
    ModeSelectionSheet(
        modeManager: .preview,
        isPresented: .constant(true),
        isLocked: false
    )
}

#Preview("Locked") {
    ModeSelectionSheet(
        modeManager: .preview,
        isPresented: .constant(true),
        isLocked: true
    )
}

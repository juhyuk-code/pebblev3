import Foundation
import Combine
import FamilyControls

/// Manages blocking modes - creation, editing, persistence
final class ModeManager: ObservableObject {

    // MARK: - Published State

    @Published private(set) var modes: [BlockingMode] = []
    @Published var selectedModeId: UUID

    // MARK: - Storage

    private let defaults: UserDefaults
    private static let modesKey = "pebble.blockingModes"
    private static let selectedModeIdKey = "pebble.selectedModeId"

    // MARK: - Computed Properties

    var selectedMode: BlockingMode? {
        modes.first { $0.id == selectedModeId }
    }

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Load saved mode ID or use default
        if let savedIdString = defaults.string(forKey: Self.selectedModeIdKey),
           let savedId = UUID(uuidString: savedIdString) {
            self.selectedModeId = savedId
        } else {
            self.selectedModeId = BlockingMode.mindfulMode.id
        }

        // Load modes
        self.modes = loadModes()

        // Ensure we have at least the default mode
        if modes.isEmpty {
            modes = [BlockingMode.mindfulMode]
            saveModes()
        }
    }

    // MARK: - Mode Selection

    func selectMode(_ mode: BlockingMode) {
        selectedModeId = mode.id
        defaults.set(mode.id.uuidString, forKey: Self.selectedModeIdKey)
    }

    // MARK: - CRUD Operations

    func createMode(name: String, selection: FamilyActivitySelection = FamilyActivitySelection()) -> BlockingMode {
        let mode = BlockingMode(name: name, selection: selection, isDefault: false)
        modes.append(mode)
        saveModes()
        return mode
    }

    func updateMode(_ mode: BlockingMode) {
        guard let index = modes.firstIndex(where: { $0.id == mode.id }) else { return }
        modes[index] = mode
        saveModes()
    }

    func deleteMode(_ mode: BlockingMode) {
        // Can't delete default modes
        guard !mode.isDefault else { return }

        modes.removeAll { $0.id == mode.id }

        // If deleted mode was selected, switch to default
        if selectedModeId == mode.id {
            selectedModeId = BlockingMode.mindfulMode.id
            defaults.set(selectedModeId.uuidString, forKey: Self.selectedModeIdKey)
        }

        saveModes()
    }

    // MARK: - Persistence

    private func saveModes() {
        do {
            let data = try JSONEncoder().encode(modes)
            defaults.set(data, forKey: Self.modesKey)
        } catch {
            print("Failed to save modes: \(error)")
        }
    }

    private func loadModes() -> [BlockingMode] {
        guard let data = defaults.data(forKey: Self.modesKey) else {
            return [BlockingMode.mindfulMode]
        }

        do {
            return try JSONDecoder().decode([BlockingMode].self, from: data)
        } catch {
            print("Failed to load modes: \(error)")
            return [BlockingMode.mindfulMode]
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension ModeManager {
    static var preview: ModeManager {
        let manager = ModeManager(defaults: UserDefaults(suiteName: "preview")!)
        return manager
    }
}
#endif

import Foundation
import Combine

/// Manages persistent app state
final class StateManager: ObservableObject {

    // MARK: - Published State

    @Published private(set) var lockState: LockState
    @Published private(set) var emergencyOverride: EmergencyOverride
    @Published private(set) var hasCompletedOnboarding: Bool

    // MARK: - Dependencies

    private let blockingService: BlockingServiceProtocol
    private let defaults: UserDefaults

    // MARK: - Initialization

    init(
        blockingService: BlockingServiceProtocol,
        defaults: UserDefaults = .standard
    ) {
        self.blockingService = blockingService
        self.defaults = defaults

        // Load persisted state
        self.lockState = Self.loadLockState(from: defaults)
        self.emergencyOverride = Self.loadEmergencyOverride(from: defaults)
        self.hasCompletedOnboarding = defaults.bool(forKey: Constants.StorageKeys.hasCompletedOnboarding)
    }

    // MARK: - State Restoration

    /// Called on app launch to restore blocking state
    func restoreState() {
        if lockState == .locked {
            let selection = blockingService.currentSelection
            blockingService.applyShield(for: selection)
            blockingService.setAppRemovalPrevention(enabled: true)
        }
    }

    // MARK: - Lock State Management

    func toggleLockState() {
        let newState = lockState.toggled
        setLockState(newState)
    }

    func setLockState(_ state: LockState) {
        lockState = state
        saveLockState(state)

        switch state {
        case .locked:
            let selection = blockingService.currentSelection
            blockingService.applyShield(for: selection)
            blockingService.setAppRemovalPrevention(enabled: true)

        case .free:
            blockingService.removeShield()
            blockingService.setAppRemovalPrevention(enabled: false)
        }
    }

    // MARK: - Emergency Override

    func useEmergencyOverride() -> Bool {
        guard emergencyOverride.isAvailable else {
            return false
        }

        emergencyOverride = emergencyOverride.useOne()
        saveEmergencyOverride(emergencyOverride)

        setLockState(.free)
        return true
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Constants.StorageKeys.hasCompletedOnboarding)
    }

    // MARK: - Persistence Helpers

    private func saveLockState(_ state: LockState) {
        defaults.set(state == .locked, forKey: Constants.StorageKeys.lockState)
    }

    private static func loadLockState(from defaults: UserDefaults) -> LockState {
        let isLocked = defaults.bool(forKey: Constants.StorageKeys.lockState)
        return isLocked ? .locked : .free
    }

    private func saveEmergencyOverride(_ override: EmergencyOverride) {
        defaults.set(override.usesRemaining, forKey: Constants.StorageKeys.emergencyUsesRemaining)
    }

    private static func loadEmergencyOverride(from defaults: UserDefaults) -> EmergencyOverride {
        // Check if key exists; if not, use default limit
        if defaults.object(forKey: Constants.StorageKeys.emergencyUsesRemaining) == nil {
            return .initial
        }
        let remaining = defaults.integer(forKey: Constants.StorageKeys.emergencyUsesRemaining)
        return EmergencyOverride(usesRemaining: remaining)
    }
}

// MARK: - Preview Helper

#if DEBUG
extension StateManager {
    static var preview: StateManager {
        StateManager(blockingService: MockBlockingService())
    }
}
#endif

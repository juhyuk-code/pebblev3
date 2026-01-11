import Foundation
import FamilyControls
import ManagedSettings
import Combine

/// Protocol for app blocking operations
protocol BlockingServiceProtocol {
    /// Request authorization for FamilyControls
    func requestAuthorization() async throws

    /// Current authorization status
    var authorizationStatus: AuthorizationStatus { get }

    /// Apply shield to selected apps
    func applyShield(for selection: FamilyActivitySelection)

    /// Remove shield from all apps
    func removeShield()

    /// Prevent app from being deleted
    func setAppRemovalPrevention(enabled: Bool)

    /// The current app selection
    var currentSelection: FamilyActivitySelection { get set }
}

/// Wrapper around FamilyControls/ManagedSettings for app blocking
final class BlockingService: BlockingServiceProtocol {

    // MARK: - Properties

    private let store = ManagedSettingsStore()
    private let authorizationCenter = AuthorizationCenter.shared

    var currentSelection: FamilyActivitySelection {
        get {
            loadSelection() ?? FamilyActivitySelection()
        }
        set {
            saveSelection(newValue)
        }
    }

    var authorizationStatus: AuthorizationStatus {
        authorizationCenter.authorizationStatus
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        try await authorizationCenter.requestAuthorization(for: .individual)
    }

    // MARK: - Shield Management

    func applyShield(for selection: FamilyActivitySelection) {
        currentSelection = selection

        // Shield applications
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens

        // Shield app categories
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        // Shield web domains (if any selected)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    // MARK: - App Removal Prevention

    func setAppRemovalPrevention(enabled: Bool) {
        store.application.denyAppRemoval = enabled
    }

    // MARK: - Persistence

    private func saveSelection(_ selection: FamilyActivitySelection) {
        do {
            let data = try PropertyListEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: Constants.StorageKeys.appSelection)
        } catch {
            print("Failed to save selection: \(error)")
        }
    }

    private func loadSelection() -> FamilyActivitySelection? {
        guard let data = UserDefaults.standard.data(forKey: Constants.StorageKeys.appSelection) else {
            return nil
        }

        do {
            return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load selection: \(error)")
            return nil
        }
    }
}

// MARK: - Mock Service for Previews

#if DEBUG
final class MockBlockingService: BlockingServiceProtocol {

    var authorizationStatus: AuthorizationStatus = .approved
    var currentSelection = FamilyActivitySelection()
    var isShieldApplied = false
    var isAppRemovalPrevented = false

    func requestAuthorization() async throws {
        // Mock: always succeeds
    }

    func applyShield(for selection: FamilyActivitySelection) {
        currentSelection = selection
        isShieldApplied = true
    }

    func removeShield() {
        isShieldApplied = false
    }

    func setAppRemovalPrevention(enabled: Bool) {
        isAppRemovalPrevented = enabled
    }
}
#endif

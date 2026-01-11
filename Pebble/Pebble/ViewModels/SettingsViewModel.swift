import Foundation
import Combine
import FamilyControls

/// ViewModel for the settings screen
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isAuthorized: Bool = false
    @Published var isRequestingAuthorization: Bool = false
    @Published var authorizationError: String?
    @Published var appSelection: FamilyActivitySelection = FamilyActivitySelection()
    @Published var showingAppPicker: Bool = false
    @Published var debugUseMockNFC: Bool = false

    // MARK: - Dependencies

    private let blockingService: BlockingServiceProtocol
    private let stateManager: StateManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var selectedAppCount: Int {
        appSelection.applicationTokens.count + appSelection.categoryTokens.count
    }

    var hasSelection: Bool {
        selectedAppCount > 0
    }

    // MARK: - Initialization

    init(blockingService: BlockingServiceProtocol, stateManager: StateManager) {
        self.blockingService = blockingService
        self.stateManager = stateManager

        // Load current state
        self.isAuthorized = blockingService.authorizationStatus == .approved
        self.appSelection = blockingService.currentSelection
        self.debugUseMockNFC = UserDefaults.standard.bool(forKey: Constants.StorageKeys.debugUseMockNFC)
    }

    // MARK: - Actions

    func requestAuthorization() async {
        isRequestingAuthorization = true
        authorizationError = nil

        do {
            try await blockingService.requestAuthorization()
            isAuthorized = true
        } catch {
            authorizationError = error.localizedDescription
            isAuthorized = false
        }

        isRequestingAuthorization = false
    }

    func saveAppSelection() {
        blockingService.currentSelection = appSelection

        // If currently locked, reapply shield with new selection
        if stateManager.lockState == .locked {
            blockingService.applyShield(for: appSelection)
        }
    }

    func toggleDebugMockNFC() {
        debugUseMockNFC.toggle()
        UserDefaults.standard.set(debugUseMockNFC, forKey: Constants.StorageKeys.debugUseMockNFC)
    }
}

// MARK: - Preview Helper

#if DEBUG
extension SettingsViewModel {
    static var preview: SettingsViewModel {
        SettingsViewModel(
            blockingService: MockBlockingService(),
            stateManager: .preview
        )
    }
}
#endif

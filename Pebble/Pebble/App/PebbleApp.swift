import SwiftUI
import FamilyControls

/// Main app entry point
@main
struct PebbleApp: App {

    // MARK: - State Objects

    @StateObject private var stateManager: StateManager
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @StateObject private var modeManager: ModeManager

    // MARK: - Services

    private let blockingService: BlockingServiceProtocol
    private let nfcService: NFCServiceProtocol

    // MARK: - Initialization

    init() {
        // Initialize services
        let blocking = BlockingService()
        let nfc = NFCServiceFactory.create()

        self.blockingService = blocking
        self.nfcService = nfc

        // Initialize mode manager first
        let modes = ModeManager()

        // Initialize state manager
        let state = StateManager(blockingService: blocking)

        // Connect StateManager to ModeManager's selection
        state.getCurrentSelection = { [weak modes] in
            modes?.selectedMode?.selection ?? FamilyActivitySelection()
        }

        // Initialize view models
        let dashboard = DashboardViewModel(
            stateManager: state,
            nfcService: nfc,
            blockingService: blocking
        )
        let settings = SettingsViewModel(blockingService: blocking, stateManager: state)

        // Wrap in StateObjects
        _stateManager = StateObject(wrappedValue: state)
        _dashboardViewModel = StateObject(wrappedValue: dashboard)
        _settingsViewModel = StateObject(wrappedValue: settings)
        _modeManager = StateObject(wrappedValue: modes)
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainTabView(
                dashboardViewModel: dashboardViewModel,
                settingsViewModel: settingsViewModel,
                modeManager: modeManager
            )
            .onAppear {
                // Restore state on app launch
                stateManager.restoreState()
            }
        }
    }
}

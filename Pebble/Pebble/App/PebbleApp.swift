import SwiftUI
import FamilyControls

/// Main app entry point
@main
struct PebbleApp: App {

    // MARK: - State Objects

    @StateObject private var stateManager: StateManager
    @StateObject private var dashboardViewModel: DashboardViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

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

        // Initialize state manager
        let state = StateManager(blockingService: blocking)

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
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainTabView(
                dashboardViewModel: dashboardViewModel,
                settingsViewModel: settingsViewModel
            )
            .onAppear {
                // Restore state on app launch
                stateManager.restoreState()
            }
        }
    }
}

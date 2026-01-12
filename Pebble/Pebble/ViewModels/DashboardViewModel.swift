import Foundation
import Combine
import FamilyControls

/// ViewModel for the main dashboard screen
@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published State

    @Published var lockState: LockState = .free
    @Published var lockedAt: Date?
    @Published var isScanning: Bool = false
    @Published var scanResult: NFCScanResult?
    @Published var showingScanResult: Bool = false
    @Published var emergencyUnlockState: EmergencyUnlockState = .idle
    @Published var emergencyUsesRemaining: Int = Constants.emergencyOverrideLimit

    // MARK: - Dependencies

    private let stateManager: StateManager
    private let nfcService: NFCServiceProtocol
    private let blockingService: BlockingServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var isLocked: Bool {
        lockState == .locked
    }

    var canUseEmergencyOverride: Bool {
        emergencyUsesRemaining > 0
    }

    var blockedAppCount: Int {
        let selection = blockingService.currentSelection
        return selection.applicationTokens.count + selection.categoryTokens.count
    }

    var blockedWebsiteCount: Int {
        blockingService.currentSelection.webDomainTokens.count
    }

    // MARK: - Initialization

    init(stateManager: StateManager, nfcService: NFCServiceProtocol, blockingService: BlockingServiceProtocol) {
        self.stateManager = stateManager
        self.nfcService = nfcService
        self.blockingService = blockingService

        // Observe state changes
        stateManager.$lockState
            .receive(on: DispatchQueue.main)
            .assign(to: &$lockState)

        stateManager.$lockedAt
            .receive(on: DispatchQueue.main)
            .assign(to: &$lockedAt)

        stateManager.$emergencyOverride
            .receive(on: DispatchQueue.main)
            .map(\.usesRemaining)
            .assign(to: &$emergencyUsesRemaining)
    }

    // MARK: - Actions

    func scanPebble() async {
        guard !isScanning else { return }

        isScanning = true

        // Check if mock NFC should be used (can be toggled at runtime)
        let service: NFCServiceProtocol
        if UserDefaults.standard.bool(forKey: Constants.StorageKeys.debugUseMockNFC) {
            service = MockNFCService()
        } else {
            service = nfcService
        }

        let result = await service.startScanning()
        scanResult = result

        if result.shouldToggleState {
            stateManager.toggleLockState()
            Haptics.notification(.success)
        } else if case .invalid = result {
            Haptics.notification(.error)
        }

        isScanning = false

        // Show result feedback (except for cancellation)
        if case .cancelled = result {
            // Don't show feedback for user cancellation
        } else {
            showingScanResult = true
        }
    }

    func dismissScanResult() {
        showingScanResult = false
        scanResult = nil
    }

    // MARK: - Emergency Override

    func startEmergencyOverride() {
        guard canUseEmergencyOverride else { return }
        emergencyUnlockState = .confirming
    }

    func confirmEmergencyOverride() {
        emergencyUnlockState = .counting(remaining: Constants.emergencyCountdownDuration)
        startCountdown()
    }

    func cancelEmergencyOverride() {
        emergencyUnlockState = .idle
    }

    private func startCountdown() {
        Task {
            var remaining = Constants.emergencyCountdownDuration

            while remaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                remaining -= 1
                emergencyUnlockState = .counting(remaining: remaining)
            }

            emergencyUnlockState = .unlocking
            _ = stateManager.useEmergencyOverride()
            Haptics.notification(.success)

            try? await Task.sleep(nanoseconds: 500_000_000) // Brief delay
            emergencyUnlockState = .idle
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension DashboardViewModel {
    static var preview: DashboardViewModel {
        DashboardViewModel(
            stateManager: .preview,
            nfcService: MockNFCService(),
            blockingService: MockBlockingService()
        )
    }
}
#endif

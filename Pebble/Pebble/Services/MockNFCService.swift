import Foundation

/// Mock NFC service for simulator and testing
final class MockNFCService: NFCServiceProtocol {

    // MARK: - Configuration

    /// Whether mock scans should return valid or invalid results
    var shouldReturnValid: Bool = true

    /// Delay before returning result (simulates real scan time)
    var scanDelay: TimeInterval = 1.5

    // MARK: - NFCServiceProtocol

    var isAvailable: Bool {
        true // Always available in mock
    }

    func startScanning() async -> NFCScanResult {
        // Simulate scanning delay
        try? await Task.sleep(nanoseconds: UInt64(scanDelay * 1_000_000_000))

        if shouldReturnValid {
            return .valid
        } else {
            return .invalid(reason: "Mock: Invalid tag")
        }
    }
}

// MARK: - Factory

enum NFCServiceFactory {

    /// Creates the appropriate NFC service based on environment
    static func create() -> NFCServiceProtocol {
        #if targetEnvironment(simulator)
        // Always use mock in simulator
        return MockNFCService()
        #else
        // On device, check debug setting
        if UserDefaults.standard.bool(forKey: Constants.StorageKeys.debugUseMockNFC) {
            return MockNFCService()
        }
        return NFCService()
        #endif
    }
}

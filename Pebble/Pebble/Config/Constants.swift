import Foundation

/// Central configuration constants for Pebble
enum Constants {

    // MARK: - NFC Configuration

    /// The secret payload that must be present on official Pebble NFC tags
    /// This is compared against the NDEF text record payload
    static let pebbleSecret = "pebble-official-key-v1"

    /// Message shown to user during NFC scanning
    static let nfcScanningMessage = "Hold your iPhone near your Pebble"

    // MARK: - Emergency Override

    /// Number of emergency override uses available (lifetime limit)
    static let emergencyOverrideLimit = 5

    /// Duration of the countdown timer in seconds before emergency unlock completes
    static let emergencyCountdownDuration: TimeInterval = 15

    // MARK: - Storage Keys

    enum StorageKeys {
        static let lockState = "pebble.lockState"
        static let lockedAt = "pebble.lockedAt"
        static let emergencyUsesRemaining = "pebble.emergencyUsesRemaining"
        static let appSelection = "pebble.appSelection"
        static let hasCompletedOnboarding = "pebble.hasCompletedOnboarding"
        static let debugUseMockNFC = "pebble.debug.useMockNFC"
    }

    // MARK: - App Info

    enum App {
        static let name = "Pebble"
        static let version = "1.0.0"
        static let minimumIOSVersion = "16.0"
    }
}

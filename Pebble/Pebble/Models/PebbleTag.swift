import Foundation

/// Represents the result of an NFC tag scan
enum NFCScanResult {
    /// Successfully scanned a valid Pebble tag
    case valid

    /// Scanned a tag but it wasn't a valid Pebble
    case invalid(reason: String)

    /// Scan was cancelled by user
    case cancelled

    /// An error occurred during scanning
    case error(Error)

    /// Whether this result should trigger a state toggle
    var shouldToggleState: Bool {
        if case .valid = self {
            return true
        }
        return false
    }

    /// User-facing message for the result
    var message: String {
        switch self {
        case .valid:
            return "Pebble detected!"
        case .invalid(let reason):
            return "Invalid tag: \(reason)"
        case .cancelled:
            return "Scan cancelled"
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
}

/// Represents a validated Pebble NFC tag
struct PebbleTag {
    /// The payload read from the tag
    let payload: String

    /// Timestamp when the tag was scanned
    let scannedAt: Date

    /// Validates if the payload matches our secret
    static func validate(payload: String) -> Bool {
        return payload == Constants.pebbleSecret
    }
}

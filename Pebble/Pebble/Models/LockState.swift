import Foundation

/// Represents the current lock state of the app
enum LockState: String, Codable {
    /// Apps are blocked - user needs to scan Pebble to unlock
    case locked

    /// Apps are accessible - user can use their phone freely
    case free

    /// Toggle to the opposite state
    var toggled: LockState {
        switch self {
        case .locked: return .free
        case .free: return .locked
        }
    }

    /// User-facing display text
    var displayText: String {
        switch self {
        case .locked: return "LOCKED"
        case .free: return "FREE"
        }
    }

    /// SF Symbol name for the state
    var iconName: String {
        switch self {
        case .locked: return "lock.fill"
        case .free: return "lock.open.fill"
        }
    }

    /// Action text for the scan button
    var actionText: String {
        switch self {
        case .locked: return "Scan to Unlock"
        case .free: return "Scan to Lock"
        }
    }
}

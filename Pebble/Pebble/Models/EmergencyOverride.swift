import Foundation

/// Tracks emergency override usage
struct EmergencyOverride: Codable {
    /// Number of uses remaining
    var usesRemaining: Int

    /// Whether emergency override is available
    var isAvailable: Bool {
        usesRemaining > 0
    }

    /// Create with default limit
    static var initial: EmergencyOverride {
        EmergencyOverride(usesRemaining: Constants.emergencyOverrideLimit)
    }

    /// Use one override (returns new state)
    func useOne() -> EmergencyOverride {
        guard isAvailable else { return self }
        return EmergencyOverride(usesRemaining: usesRemaining - 1)
    }
}

/// State of an ongoing emergency unlock
enum EmergencyUnlockState: Equatable {
    /// Not in emergency unlock flow
    case idle

    /// Showing warning confirmation
    case confirming

    /// Countdown in progress
    case counting(remaining: TimeInterval)

    /// Countdown complete, unlocking
    case unlocking

    /// Whether the countdown is active
    var isCountingDown: Bool {
        if case .counting = self {
            return true
        }
        return false
    }
}

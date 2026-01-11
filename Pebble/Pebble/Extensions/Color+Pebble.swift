import SwiftUI

extension Color {

    // MARK: - Brand Colors

    /// Primary brand color - used for main actions
    static let pebblePrimary = Color("PebblePrimary", bundle: nil)

    /// Secondary brand color
    static let pebbleSecondary = Color("PebbleSecondary", bundle: nil)

    // MARK: - State Colors

    /// Color indicating locked state
    static let pebbleLocked = Color.red

    /// Color indicating free/unlocked state
    static let pebbleFree = Color.green

    // MARK: - Semantic Colors

    /// Background color for cards and containers
    static let pebbleCardBackground = Color(.systemBackground)

    /// Secondary background
    static let pebbleBackground = Color(.systemGroupedBackground)

    // MARK: - Helpers

    /// Returns the appropriate color for a lock state
    static func forState(_ state: LockState) -> Color {
        switch state {
        case .locked: return .pebbleLocked
        case .free: return .pebbleFree
        }
    }
}

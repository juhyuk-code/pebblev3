# Pebble iOS App - Implementation Plan

## Executive Summary

Pebble is an iOS app that introduces physical friction to digital habits by requiring users to tap their phone against an NFC-enabled hardware tag to lock/unlock distracting apps. The app leverages Apple's Screen Time API (FamilyControls/ManagedSettings) for app blocking and CoreNFC for tag validation.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Pebble App                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Views     │  │  ViewModels │  │       Services          │  │
│  │  (SwiftUI)  │◄─┤   (State)   │◄─┤                         │  │
│  └─────────────┘  └─────────────┘  │  ┌───────────────────┐  │  │
│                                     │  │  NFCService       │  │  │
│                                     │  │  (CoreNFC)        │  │  │
│                                     │  └───────────────────┘  │  │
│                                     │  ┌───────────────────┐  │  │
│                                     │  │  BlockingService  │  │  │
│                                     │  │  (FamilyControls) │  │  │
│                                     │  └───────────────────┘  │  │
│                                     │  ┌───────────────────┐  │  │
│                                     │  │  StateManager     │  │  │
│                                     │  │  (Persistence)    │  │  │
│                                     │  └───────────────────┘  │  │
│                                     └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
Pebble/
├── App/
│   ├── PebbleApp.swift              # App entry point
│   └── AppDelegate.swift            # App lifecycle handling
│
├── Models/
│   ├── LockState.swift              # Lock state enum (locked/free)
│   ├── PebbleTag.swift              # NFC tag validation model
│   └── EmergencyOverride.swift      # Override tracking model
│
├── Services/
│   ├── NFCService.swift             # CoreNFC tag reading & validation
│   ├── BlockingService.swift        # FamilyControls/ManagedSettings wrapper
│   ├── StateManager.swift           # Persistent state management
│   └── MockNFCService.swift         # Debug/simulator mock
│
├── ViewModels/
│   ├── DashboardViewModel.swift     # Main screen state
│   └── SettingsViewModel.swift      # Settings/config state
│
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift      # Main screen
│   │   ├── StatusIndicator.swift    # Lock status display
│   │   └── ScanButton.swift         # NFC trigger button
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift       # Configuration screen
│   │   ├── AppPickerView.swift      # FamilyActivityPicker wrapper
│   │   └── EmergencyOverrideView.swift
│   │
│   └── Components/
│       ├── PebbleButton.swift       # Reusable button styles
│       └── CountdownOverlay.swift   # Emergency unlock countdown
│
├── Extensions/
│   ├── Color+Pebble.swift           # Brand colors
│   └── View+Haptics.swift           # Haptic feedback helpers
│
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizable.strings
│
└── Config/
    ├── Pebble.entitlements          # FamilyControls entitlement
    ├── Info.plist                   # NFC usage description
    └── Constants.swift              # Hardcoded secrets, config
```

---

## Core Components Breakdown

### 1. NFCService (CoreNFC Integration)

**File:** `Services/NFCService.swift`

**Responsibilities:**
- Initiate NFC scanning sessions via `NFCNDEFReaderSession`
- Read NDEF payload from detected tags
- Validate payload against manufacturer secret
- Return scan result (valid/invalid/error)

**Key Implementation Details:**
```swift
// Manufacturer secret - hardcoded validation string
private let PEBBLE_SECRET = "pebble-official-key-v1"

// NFCNDEFReaderSessionDelegate methods:
// - readerSession(_:didDetectNDEFs:)
// - readerSession(_:didInvalidateWithError:)
```

**Validation Flow:**
1. User taps "Scan" button
2. System presents NFC scanning UI
3. User taps phone to Pebble tag
4. Read NDEF text record from tag
5. Compare payload to `PEBBLE_SECRET`
6. Return `.valid` or `.invalid`

---

### 2. BlockingService (Screen Time API)

**File:** `Services/BlockingService.swift`

**Responsibilities:**
- Request FamilyControls authorization
- Manage app selection via `FamilyActivitySelection`
- Apply/remove app shields via `ManagedSettingsStore`
- Prevent app removal when locked

**Key Frameworks:**
```swift
import FamilyControls
import ManagedSettings
import DeviceActivity
```

**Core Operations:**

| Operation | Framework | Method |
|-----------|-----------|--------|
| Request authorization | FamilyControls | `AuthorizationCenter.shared.requestAuthorization(for: .individual)` |
| Store app selection | FamilyControls | `FamilyActivitySelection` |
| Apply shield | ManagedSettings | `store.shield.applications = selection.applicationTokens` |
| Remove shield | ManagedSettings | `store.shield.applications = nil` |
| Prevent app deletion | ManagedSettings | `store.application.denyAppRemoval = true` |

**Shield Persistence:**
- `ManagedSettingsStore` automatically persists across app restarts and reboots
- No additional persistence logic needed for the shield itself
- Lock *state* stored separately in `StateManager`

---

### 3. StateManager (Persistence)

**File:** `Services/StateManager.swift`

**Responsibilities:**
- Persist lock state across app lifecycle
- Track emergency override usage count
- Store user's app selection (via FamilyActivitySelection's Codable conformance)

**Storage Strategy:**
```swift
// Primary: UserDefaults with App Group (for future widget support)
// Keys:
// - "pebble.lockState" -> Bool (true = locked)
// - "pebble.emergencyUsesRemaining" -> Int (default: 5)
// - "pebble.appSelection" -> Data (encoded FamilyActivitySelection)
```

**State Restoration on Launch:**
```swift
func restoreState() {
    if isLocked {
        blockingService.applyShield(for: savedSelection)
    }
}
```

---

### 4. Emergency Override System

**File:** `Models/EmergencyOverride.swift` + `Views/EmergencyOverrideView.swift`

**Friction Mechanisms:**
1. **15-second countdown timer** - Cannot skip or cancel
2. **Limited uses** - 5 lifetime unlocks (stored in StateManager)
3. **Warning modal** - Explains consequences before starting countdown

**Flow:**
```
[Tap Emergency Button]
        ↓
[Warning Modal: "Are you sure? X uses remaining"]
        ↓
[Confirm] → [15s Countdown Overlay]
        ↓
[Countdown Complete] → [Decrement uses, Unlock]
```

---

### 5. Dashboard UI

**File:** `Views/Dashboard/DashboardView.swift`

**Layout:**
```
┌─────────────────────────────────┐
│         🔒 / 🔓                 │  ← Large status icon
│      "LOCKED" / "FREE"          │  ← Status text
│                                 │
│    ┌─────────────────────┐      │
│    │                     │      │
│    │   [SCAN PEBBLE]     │      │  ← Primary action button
│    │                     │      │
│    └─────────────────────┘      │
│                                 │
│    ──────────────────────       │
│                                 │
│    ⚙️ Settings                  │  ← Disabled when locked
│    🆘 Emergency Unlock          │  ← Always accessible
│                                 │
└─────────────────────────────────┘
```

**State-Dependent UI:**
| State | Scan Button | Settings | App Picker |
|-------|-------------|----------|------------|
| Free | "Lock Apps" | Enabled | Enabled |
| Locked | "Unlock" | Disabled | Hidden |

---

## Implementation Phases

### Phase 1: Project Setup & Core Infrastructure
**Estimated Complexity: Low**

**Tasks:**
1. Create Xcode project with SwiftUI lifecycle
2. Configure entitlements:
   - `com.apple.developer.family-controls`
   - Near Field Communication Tag Reading
3. Add Info.plist entries:
   - `NFCReaderUsageDescription`
   - `NSFaceIDUsageDescription` (optional, for future)
4. Create folder structure and placeholder files
5. Define `Constants.swift` with manufacturer secret
6. Implement `LockState` enum

**Deliverables:**
- Buildable Xcode project
- All entitlements configured
- Basic app shell

---

### Phase 2: State Management & Persistence
**Estimated Complexity: Low-Medium**

**Tasks:**
1. Implement `StateManager` with UserDefaults
2. Create `EmergencyOverride` model with use tracking
3. Add state restoration on app launch
4. Write unit tests for state transitions

**Deliverables:**
- Persistent lock state
- Emergency override tracking
- State restoration working

---

### Phase 3: Screen Time API Integration
**Estimated Complexity: Medium-High**

**Tasks:**
1. Implement `BlockingService`
2. Request FamilyControls authorization
3. Integrate `FamilyActivityPicker` for app selection
4. Implement shield application/removal
5. Add app removal prevention
6. Test shield persistence across reboots

**Deliverables:**
- Working app blocking
- App picker integration
- Shields persist correctly

**Gotchas:**
- FamilyControls requires physical device testing
- Authorization can only be requested once per app install
- App tokens are opaque - cannot inspect app names directly

---

### Phase 4: NFC Integration
**Estimated Complexity: Medium**

**Tasks:**
1. Implement `NFCService` with CoreNFC
2. Add NDEF payload parsing
3. Implement secret validation logic
4. Create `MockNFCService` for simulator
5. Add debug toggle in Settings

**Deliverables:**
- NFC tag scanning works on device
- Mock scanning works in simulator
- Validation correctly accepts/rejects tags

**Gotchas:**
- CoreNFC not available in simulator
- Need to handle session invalidation gracefully
- Background scanning not supported (foreground only)

---

### Phase 5: Dashboard UI
**Estimated Complexity: Low-Medium**

**Tasks:**
1. Build `DashboardView` with status indicator
2. Create animated `ScanButton`
3. Add haptic feedback for state changes
4. Implement state-dependent UI (disable settings when locked)
5. Add scan result feedback (success/failure animations)

**Deliverables:**
- Polished main screen
- Clear status indication
- Smooth interactions

---

### Phase 6: Settings & Configuration
**Estimated Complexity: Low-Medium**

**Tasks:**
1. Build `SettingsView`
2. Integrate `FamilyActivityPicker` via `AppPickerView`
3. Add debug mode toggle (for mock NFC)
4. Display emergency uses remaining

**Deliverables:**
- Complete settings screen
- App selection working
- Debug controls available

---

### Phase 7: Emergency Override
**Estimated Complexity: Low**

**Tasks:**
1. Build `EmergencyOverrideView` with countdown
2. Add warning modal
3. Implement use tracking and limits
4. Add countdown animation

**Deliverables:**
- Working emergency unlock
- Proper friction (countdown, warnings)
- Use limit enforcement

---

### Phase 8: Polish & Edge Cases
**Estimated Complexity: Medium**

**Tasks:**
1. Handle authorization denial gracefully
2. Add onboarding flow for first launch
3. Improve error messaging
4. Add app icon and launch screen
5. Localization support
6. Accessibility audit

**Deliverables:**
- Production-ready app
- Graceful error handling
- Professional polish

---

## Technical Considerations

### Entitlements Required

```xml
<!-- Pebble.entitlements -->
<key>com.apple.developer.family-controls</key>
<dict>
    <key>FamilyControlsLevel</key>
    <string>individual</string>
</dict>
```

### Info.plist Entries

```xml
<key>NFCReaderUsageDescription</key>
<string>Pebble uses NFC to read your physical Pebble tag for locking and unlocking.</string>

<key>NSUserTrackingUsageDescription</key>
<!-- Not needed unless adding analytics -->
```

### Testing Strategy

| Component | Simulator | Physical Device |
|-----------|-----------|-----------------|
| UI/State | ✅ Full testing | ✅ |
| NFC | 🔶 Mock only | ✅ Required |
| FamilyControls | ❌ Not available | ✅ Required |
| Persistence | ✅ | ✅ |

### Debug Mode Implementation

```swift
#if DEBUG
static var useMockNFC: Bool {
    get { UserDefaults.standard.bool(forKey: "debug.useMockNFC") }
    set { UserDefaults.standard.set(newValue, forKey: "debug.useMockNFC") }
}
#endif
```

---

## Security Considerations

### NFC Tag Validation

**Current Approach (v1):**
- Simple string comparison against hardcoded secret
- Pros: Simple, works for MVP
- Cons: Secret can be reverse-engineered from binary

**Future Improvements (v2+):**
- Use NFC tag UID + HMAC for validation
- Challenge-response with secure enclave
- Server-side validation for premium features

### State Tampering Prevention

- `ManagedSettingsStore` is system-managed, not user-accessible
- Lock state in UserDefaults can be tampered via backup restore
- Future: Use Keychain with `kSecAttrAccessibleAfterFirstUnlock`

---

## Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| CoreNFC | System Framework | NFC tag reading |
| FamilyControls | System Framework | Screen Time authorization |
| ManagedSettings | System Framework | App shielding |
| DeviceActivity | System Framework | (Future: Scheduled unlocks) |

**No third-party dependencies required for MVP.**

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Apple rejects due to policy | Low | High | Follow Screen Time API guidelines strictly |
| FamilyControls API changes | Low | Medium | Pin to iOS 16+ baseline |
| NFC tag cloning | Medium | Low | Document as known limitation, plan HMAC upgrade |
| User loses Pebble hardware | High | Medium | Emergency override system |

---

## Success Criteria

1. **Functional:** App successfully blocks selected apps when locked
2. **Persistent:** Lock state survives reboots
3. **Secure:** Only official Pebble tags can toggle state
4. **Usable:** Clear UI with obvious status indication
5. **Safe:** Emergency override provides reliable escape hatch

---

## Next Steps

1. **Approve this plan** - Review and confirm architecture decisions
2. **Begin Phase 1** - Project setup and infrastructure
3. **Iterate** - Each phase builds on the previous

---

*Plan Version: 1.0*
*Last Updated: January 2025*

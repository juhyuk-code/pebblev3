# Pebble iOS App

An iOS app that introduces physical friction to digital habits using NFC tags.

## Requirements

- Xcode 15.0+
- iOS 16.0+
- XcodeGen (for project generation)

## Setup

1. Install XcodeGen:
   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:
   ```bash
   cd Pebble
   xcodegen generate
   ```

3. Open `Pebble.xcodeproj` in Xcode

4. Configure your development team in Signing & Capabilities

5. Build and run on a physical device (NFC requires real hardware)

## Project Structure

```
Pebble/
├── App/                    # App entry point
├── Models/                 # Data models
├── Services/               # Business logic services
│   ├── NFCService.swift    # CoreNFC integration
│   ├── BlockingService.swift # FamilyControls integration
│   └── StateManager.swift  # Persistent state
├── ViewModels/             # SwiftUI view models
├── Views/                  # SwiftUI views
│   ├── Dashboard/          # Main screen
│   ├── Settings/           # Configuration
│   └── Components/         # Reusable UI
├── Extensions/             # Swift extensions
├── Resources/              # Assets, strings
└── Config/                 # Entitlements, constants
```

## Debug Mode

For testing in the iOS Simulator or without a physical Pebble tag:

1. Go to Settings in the app
2. Enable "Use Mock NFC Scanner" under Debug section
3. The mock scanner will simulate a successful Pebble scan

## Entitlements

The app requires these capabilities:
- **Family Controls** - For Screen Time API access
- **NFC Tag Reading** - For reading Pebble tags

## Architecture

- **MVVM Pattern** - Views, ViewModels, and Models
- **Service Layer** - NFCService, BlockingService, StateManager
- **Dependency Injection** - Services injected into ViewModels

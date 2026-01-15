# feat: Audio Toggle Menu Bar App

**Type:** Enhancement
**Created:** 2026-01-15
**Status:** Planning

## Overview

Build a native macOS menu bar app called **AudioToggle** that allows users to quickly cycle between selected audio output devices using a customizable global keyboard shortcut. The app provides a one-click installation experience and eliminates the need for manual Automator/System Settings configuration.

## Problem Statement / Motivation

Switching audio outputs on macOS currently requires either:
1. Clicking the menu bar sound icon and selecting a device (multiple clicks)
2. Setting up a custom solution with shell scripts, Automator Quick Actions, and System Settings keyboard shortcuts (tedious, ~15 minutes per user account)

The manual approach involves:
- Installing `switchaudio-osx` via Homebrew
- Creating a shell script in `~/.scripts/`
- Creating an Automator Quick Action
- Configuring a keyboard shortcut in System Settings

This is error-prone and must be repeated for each user account on a shared Mac. A native app with built-in hotkey support solves this entirely.

## Proposed Solution

A lightweight SwiftUI menu bar app that:
1. **Enumerates all audio output devices** using CoreAudio
2. **Lets users select which devices to cycle through** (stored in UserDefaults)
3. **Registers a global keyboard shortcut** that works system-wide
4. **Cycles to the next device** when the hotkey is pressed
5. **Shows a notification** confirming the switch
6. **Installs via Homebrew Cask** or direct download

### User Experience

```
1. brew install --cask audio-toggle  (or download .dmg)
2. Launch app → appears in menu bar
3. Click menu bar icon → select devices to cycle
4. Set preferred hotkey (e.g., fn+F10, ⌥⇧A)
5. Done! Press hotkey to cycle audio outputs
```

## Technical Approach

### Architecture

```
AudioToggle/
├── AudioToggleApp.swift           # App entry point with MenuBarExtra
├── Models/
│   └── AudioDevice.swift          # Device model with id, name, uid
├── Services/
│   ├── AudioService.swift         # CoreAudio wrapper (SimplyCoreAudio)
│   └── PreferencesService.swift   # UserDefaults persistence
├── Views/
│   ├── MenuBarView.swift          # Main menu bar popover content
│   ├── DeviceSelectionView.swift  # Multi-select device picker
│   └── SettingsView.swift         # Hotkey configuration
└── Resources/
    └── Assets.xcassets            # App icons, menu bar icons
```

### Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| UI Framework | SwiftUI + MenuBarExtra | Native macOS 13+ API for menu bar apps |
| Audio API | [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) | Clean Swift wrapper around CoreAudio |
| Global Hotkeys | [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | User-configurable, Mac App Store compatible |
| Storage | UserDefaults | Simple, no external dependencies |
| Distribution | Homebrew Cask + GitHub Releases | Easy install via `brew install --cask` |

### Key Dependencies

```swift
// Package.swift dependencies
.package(url: "https://github.com/rnine/SimplyCoreAudio.git", from: "4.0.0"),
.package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "2.0.0")
```

### Implementation Phases

#### Phase 1: Core Audio Service

**Goal:** Enumerate devices and switch audio output programmatically.

**Tasks:**
- [ ] Create Xcode project with SwiftUI App lifecycle
- [ ] Add SimplyCoreAudio package dependency
- [ ] Create `AudioDevice` model
- [ ] Create `AudioService` with methods:
  - `getAllOutputDevices() -> [AudioDevice]`
  - `getCurrentOutputDevice() -> AudioDevice?`
  - `setOutputDevice(_ device: AudioDevice)`
  - `subscribeToDeviceChanges()`
- [ ] Write unit tests for AudioService

**Files to create:**
- `AudioToggle/Models/AudioDevice.swift`
- `AudioToggle/Services/AudioService.swift`
- `AudioToggleTests/AudioServiceTests.swift`

**AudioDevice.swift (pseudo):**
```swift
struct AudioDevice: Identifiable, Codable, Equatable {
    let id: AudioObjectID
    let uid: String        // Stable identifier across reconnections
    let name: String
    var isSelected: Bool   // User wants to include in cycle

    var displayName: String {
        // Clean up names like "CalDigit TS4 Audio - Front" → "CalDigit TS4"
    }
}
```

**AudioService.swift (pseudo):**
```swift
import SimplyCoreAudio

@Observable
class AudioService {
    private let simplyCA = SimplyCoreAudio()
    private(set) var outputDevices: [AudioDevice] = []
    private(set) var currentDevice: AudioDevice?

    init() {
        refreshDevices()
        observeDeviceChanges()
    }

    func refreshDevices() {
        outputDevices = simplyCA.allOutputDevices.map { AudioDevice(from: $0) }
        currentDevice = outputDevices.first { $0.uid == simplyCA.defaultOutputDevice?.uid }
    }

    func setOutputDevice(_ device: AudioDevice) {
        guard let scaDevice = simplyCA.allOutputDevices.first(where: { $0.uid == device.uid }) else { return }
        scaDevice.isDefaultOutputDevice = true
        showNotification(switched: device)
    }

    func cycleToNextDevice(in selectedDevices: [AudioDevice]) {
        guard let current = currentDevice,
              let currentIndex = selectedDevices.firstIndex(of: current) else {
            // Set to first selected device
            if let first = selectedDevices.first { setOutputDevice(first) }
            return
        }
        let nextIndex = (currentIndex + 1) % selectedDevices.count
        setOutputDevice(selectedDevices[nextIndex])
    }
}
```

---

#### Phase 2: Menu Bar UI

**Goal:** Create the menu bar interface with device selection.

**Tasks:**
- [ ] Configure app as Agent (no Dock icon) in Info.plist
- [ ] Create MenuBarExtra with `.window` style
- [ ] Build DeviceSelectionView with checkboxes for each device
- [ ] Show current device indicator
- [ ] Add "Quit" button
- [ ] Create PreferencesService for storing selected device UIDs

**Files to create:**
- `AudioToggle/AudioToggleApp.swift`
- `AudioToggle/Views/MenuBarView.swift`
- `AudioToggle/Views/DeviceSelectionView.swift`
- `AudioToggle/Services/PreferencesService.swift`

**AudioToggleApp.swift (pseudo):**
```swift
import SwiftUI

@main
struct AudioToggleApp: App {
    @State private var audioService = AudioService()
    @State private var preferencesService = PreferencesService()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                audioService: audioService,
                preferencesService: preferencesService
            )
        } label: {
            Image(systemName: "speaker.wave.2.fill")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(preferencesService: preferencesService)
        }
    }
}
```

**MenuBarView.swift (pseudo):**
```swift
struct MenuBarView: View {
    @Bindable var audioService: AudioService
    @Bindable var preferencesService: PreferencesService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audio Output")
                .font(.headline)

            Divider()

            // Current device indicator
            if let current = audioService.currentDevice {
                Label(current.displayName, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            Divider()

            // Device selection
            Text("Cycle between:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(audioService.outputDevices) { device in
                Toggle(device.displayName, isOn: binding(for: device))
            }

            Divider()

            // Hotkey display
            HStack {
                Text("Shortcut:")
                KeyboardShortcuts.Recorder(for: .cycleAudioDevice)
            }

            Divider()

            Button("Quit AudioToggle") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 280)
    }
}
```

---

#### Phase 3: Global Hotkey

**Goal:** Register user-configurable global keyboard shortcut.

**Tasks:**
- [ ] Add KeyboardShortcuts package dependency
- [ ] Define shortcut name extension
- [ ] Add KeyboardShortcuts.Recorder to UI
- [ ] Register hotkey handler to cycle devices
- [ ] Set sensible default (e.g., ⌥⇧A)

**Files to modify:**
- `AudioToggle/AudioToggleApp.swift`
- `AudioToggle/Views/MenuBarView.swift`

**New file:**
- `AudioToggle/Shortcuts.swift`

**Shortcuts.swift:**
```swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let cycleAudioDevice = Self("cycleAudioDevice")
}
```

**Handler registration in AudioToggleApp:**
```swift
.onAppear {
    KeyboardShortcuts.onKeyUp(for: .cycleAudioDevice) {
        let selectedDevices = preferencesService.selectedDevices(from: audioService.outputDevices)
        audioService.cycleToNextDevice(in: selectedDevices)
    }
}
```

---

#### Phase 4: Notifications & Polish

**Goal:** Provide user feedback and improve UX.

**Tasks:**
- [ ] Request notification permission on first launch
- [ ] Show notification when audio switches
- [ ] Add app icon (simple speaker graphic)
- [ ] Add menu bar icon variants (dark/light mode)
- [ ] Handle edge cases:
  - No devices selected → show alert
  - Only one device selected → just switch to it (no cycle)
  - Selected device disconnected → skip to next

**Notification code:**
```swift
func showNotification(switched device: AudioDevice) {
    let content = UNMutableNotificationContent()
    content.title = "Audio Output"
    content.body = "Switched to \(device.displayName)"
    content.sound = nil  // Silent

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil
    )
    UNUserNotificationCenter.current().add(request)
}
```

---

#### Phase 5: Distribution

**Goal:** Make the app easily installable.

**Tasks:**
- [ ] Create app icons (1024x1024 master)
- [ ] Configure code signing (Developer ID or self-signed for testing)
- [ ] Create DMG installer using `create-dmg`
- [ ] Set up GitHub Actions for automated builds
- [ ] Create Homebrew Cask formula in personal tap
- [ ] Write README with installation instructions

**Homebrew Cask formula (`audio-toggle.rb`):**
```ruby
cask "audio-toggle" do
  version "1.0.0"
  sha256 "abc123..."  # Generated from release artifact

  url "https://github.com/YOUR_USERNAME/audio-toggle/releases/download/v#{version}/AudioToggle-#{version}.dmg"
  name "AudioToggle"
  desc "Menu bar app to quickly cycle between audio output devices with a hotkey"
  homepage "https://github.com/YOUR_USERNAME/audio-toggle"

  app "AudioToggle.app"

  zap trash: [
    "~/Library/Preferences/com.yourname.AudioToggle.plist",
  ]
end
```

**GitHub Actions workflow (`.github/workflows/build.yml`):**
```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: |
          xcodebuild -scheme AudioToggle -configuration Release -archivePath build/AudioToggle.xcarchive archive
          xcodebuild -exportArchive -archivePath build/AudioToggle.xcarchive -exportPath build -exportOptionsPlist ExportOptions.plist

      - name: Create DMG
        run: |
          brew install create-dmg
          create-dmg --volname "AudioToggle" --window-size 400 300 "AudioToggle-${{ github.ref_name }}.dmg" build/AudioToggle.app

      - name: Upload Release
        uses: softprops/action-gh-release@v1
        with:
          files: AudioToggle-*.dmg
```

## Alternative Approaches Considered

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **CLI installer script** | Simple, no compilation | Can't auto-register hotkeys, requires manual System Settings | Rejected |
| **Raycast/Alfred extension** | Quick for power users | Requires Raycast/Alfred installed | Could add later as bonus |
| **Native app (this plan)** | Best UX, single install, built-in hotkeys | Requires Xcode, code signing | **Selected** |
| **Electron app** | Cross-platform | 100MB+ bundle, slow startup | Rejected |

## Acceptance Criteria

### Functional Requirements

- [ ] App appears in menu bar with speaker icon
- [ ] App does NOT appear in Dock
- [ ] User can see all available audio output devices
- [ ] User can select 2+ devices to cycle between
- [ ] User can record a custom global hotkey
- [ ] Pressing hotkey cycles to next selected device
- [ ] Notification appears confirming the switch
- [ ] Selected devices persist across app restarts
- [ ] App handles device connect/disconnect gracefully

### Non-Functional Requirements

- [ ] App launches in < 1 second
- [ ] Memory usage < 30MB
- [ ] No accessibility permissions required (KeyboardShortcuts handles this)
- [ ] Works on macOS 13 Ventura and later
- [ ] Supports both Intel and Apple Silicon (Universal binary)

### Quality Gates

- [ ] All unit tests pass
- [ ] App is code-signed (at minimum ad-hoc for local testing)
- [ ] README includes installation instructions
- [ ] Homebrew Cask formula validates with `brew audit`

## Success Metrics

1. **Installation success** - Users can install with single `brew install --cask audio-toggle` command
2. **Setup time** - < 30 seconds from install to first hotkey press (vs ~15 minutes manual)
3. **Reliability** - Hotkey works 100% of the time when app is running

## Dependencies & Prerequisites

- Xcode 15+ (for building)
- macOS 13+ (runtime requirement for MenuBarExtra)
- GitHub account (for releases and Homebrew tap)
- Optional: Apple Developer account (for notarization, not required for GitHub distribution)

## Risk Analysis & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CoreAudio API changes | Low | High | Use SimplyCoreAudio abstraction layer |
| KeyboardShortcuts deprecation | Low | Medium | Library is actively maintained, could fall back to HotKey |
| macOS removes MenuBarExtra | Very Low | High | Would require AppKit rewrite |
| Code signing issues | Medium | Medium | Document self-signing for local use |

## Resource Requirements

- **Development time:** This is a straightforward SwiftUI app. Core functionality can be built incrementally.
- **Infrastructure:** GitHub (free tier sufficient for releases)
- **Ongoing:** Minimal - may need updates for major macOS versions

## Future Considerations

1. **Input device toggling** - Same concept for microphones
2. **Profiles** - "Work" vs "Home" device sets
3. **Auto-switch rules** - Like AudioPriorityBar, auto-switch when devices connect
4. **Volume sync** - Maintain volume level when switching
5. **Mac App Store** - If there's demand, could publish there (requires notarization)

## References & Research

### Internal References
- User's existing script: `~/.scripts/toggle-audio.sh`
- Proven pattern: Uses `SwitchAudioSource` CLI under the hood

### External References
- [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) - Swift CoreAudio wrapper
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global hotkey library
- [AudioPriorityBar](https://github.com/tobi/AudioPriorityBar) - Similar project for reference
- [MenuBarExtra Tutorial](https://nilcoalescing.com/blog/BuildAMacOSMenuBarUtilityInSwiftUI/) - SwiftUI menu bar guide
- [Homebrew Cask Docs](https://docs.brew.sh/Adding-Software-to-Homebrew) - Distribution guide

### Similar Projects
- [AudioPriorityBar](https://github.com/tobi/AudioPriorityBar) - Priority-based audio switching
- [AudioProfiles](https://github.com/Zakay/AudioProfiles) - Rule-based audio switching
- [switchaudio-osx](https://github.com/deweller/switchaudio-osx) - CLI tool (current solution)

---

*Generated with Claude Code on 2026-01-15*

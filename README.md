# AudioToggle

A lightweight macOS menu bar app to quickly cycle between audio output devices with a global keyboard shortcut.

## Features

- Menu bar app with no Dock icon
- Cycle between selected audio devices with a customizable hotkey
- See all available output devices
- Native notifications when switching
- Persists preferences across restarts

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15+ (for building from source)

## Installation

### Option 1: Homebrew (Coming Soon)

```bash
brew install --cask audio-toggle
```

### Option 2: Download Release

Download the latest `.dmg` from [Releases](https://github.com/barcartcapital/audio-toggle/releases).

### Option 3: Build from Source

```bash
# Clone the repository
git clone https://github.com/barcartcapital/audio-toggle.git
cd audio-toggle

# Install xcodegen (if not already installed)
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Open in Xcode
open AudioToggle.xcodeproj

# Or build from command line
xcodebuild -project AudioToggle.xcodeproj -scheme AudioToggle -configuration Release
```

## Usage

1. **Launch AudioToggle** - The app appears in your menu bar with a headphones icon
2. **Select devices** - Click the menu bar icon and check the devices you want to cycle between
3. **Set hotkey** - Click in the "Shortcut" field and press your preferred key combination (e.g., `fn+F10` or `Option+Shift+A`)
4. **Toggle!** - Press your hotkey to cycle to the next audio output device

## How It Works

AudioToggle uses:
- **CoreAudio** (via [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio)) for audio device management
- **[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)** for global hotkey registration
- **SwiftUI MenuBarExtra** for the native menu bar interface

## Development

### Project Structure

```
Sources/AudioToggle/
├── AudioToggleApp.swift      # App entry point with MenuBarExtra
├── Models/
│   └── AudioDevice.swift     # AudioOutputDevice model
├── Services/
│   ├── AudioService.swift    # CoreAudio integration
│   └── PreferencesService.swift  # UserDefaults persistence
├── Views/
│   └── MenuBarView.swift     # Menu bar UI
├── Shortcuts.swift           # Global hotkey definition
└── Info.plist               # App configuration
```

### Dependencies

- [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) - Swift wrapper for CoreAudio
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global keyboard shortcuts

### Building

The project uses [xcodegen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from `project.yml`:

```bash
xcodegen generate
xcodebuild -scheme AudioToggle -configuration Release
```

## License

MIT License - See [LICENSE](LICENSE) for details.

## Credits

Built with [Claude Code](https://claude.ai/code)

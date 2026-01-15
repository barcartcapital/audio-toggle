import SwiftUI
import KeyboardShortcuts

@main
struct AudioToggleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                audioService: AppDelegate.shared.audioService,
                preferencesService: AppDelegate.shared.preferencesService
            )
        } label: {
            Label("AudioToggle", systemImage: "headphones")
        }
        .menuBarExtraStyle(.window)
    }
}

/// AppDelegate to handle app lifecycle events and register hotkey at launch
class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()

    let audioService = AudioService()
    let preferencesService = PreferencesService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register hotkey immediately at app launch
        setupHotkey()
    }

    private func setupHotkey() {
        KeyboardShortcuts.onKeyUp(for: .cycleAudioDevice) { [weak self] in
            guard let self = self else { return }
            let selectedDevices = self.preferencesService.selectedDevices(from: self.audioService.outputDevices)
            self.audioService.cycleToNextDevice(in: selectedDevices)
        }
    }
}

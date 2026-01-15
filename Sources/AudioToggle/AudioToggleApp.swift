import SwiftUI
import KeyboardShortcuts

@main
struct AudioToggleApp: App {
    @State private var audioService = AudioService()
    @State private var preferencesService = PreferencesService()
    @State private var hotkeyRegistered = false

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                audioService: audioService,
                preferencesService: preferencesService
            )
            .onAppear {
                setupHotkeyOnce()
            }
        } label: {
            Label("AudioToggle", systemImage: "headphones")
        }
        .menuBarExtraStyle(.window)
    }

    private func setupHotkeyOnce() {
        // Only register the hotkey handler once
        guard !hotkeyRegistered else { return }
        hotkeyRegistered = true

        // Capture services for the closure
        let prefs = preferencesService
        let audio = audioService

        KeyboardShortcuts.onKeyUp(for: .cycleAudioDevice) {
            let selectedDevices = prefs.selectedDevices(from: audio.outputDevices)
            audio.cycleToNextDevice(in: selectedDevices)
        }
    }
}

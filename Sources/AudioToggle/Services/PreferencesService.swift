import Foundation

/// Service for persisting user preferences to UserDefaults
@Observable
final class PreferencesService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let selectedDeviceUIDs = "selectedDeviceUIDs"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    /// UIDs of devices selected for cycling
    var selectedDeviceUIDs: Set<String> {
        didSet {
            saveSelectedDevices()
        }
    }

    /// Whether the user has completed initial setup
    var hasCompletedOnboarding: Bool {
        didSet {
            defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }

    init() {
        // Load selected device UIDs
        if let savedUIDs = defaults.stringArray(forKey: Keys.selectedDeviceUIDs) {
            selectedDeviceUIDs = Set(savedUIDs)
        } else {
            selectedDeviceUIDs = []
        }

        hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
    }

    /// Check if a device is selected for cycling
    func isSelected(_ device: AudioOutputDevice) -> Bool {
        selectedDeviceUIDs.contains(device.uid)
    }

    /// Toggle selection state for a device
    func toggleSelection(_ device: AudioOutputDevice) {
        if selectedDeviceUIDs.contains(device.uid) {
            selectedDeviceUIDs.remove(device.uid)
        } else {
            selectedDeviceUIDs.insert(device.uid)
        }
    }

    /// Get the selected devices from a list of available devices
    /// Maintains the order of the available devices list
    func selectedDevices(from availableDevices: [AudioOutputDevice]) -> [AudioOutputDevice] {
        availableDevices.filter { selectedDeviceUIDs.contains($0.uid) }
    }

    /// Reset all preferences to defaults
    func reset() {
        selectedDeviceUIDs = []
        hasCompletedOnboarding = false
    }

    // MARK: - Private

    private func saveSelectedDevices() {
        defaults.set(Array(selectedDeviceUIDs), forKey: Keys.selectedDeviceUIDs)
    }
}

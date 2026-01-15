import Foundation
import SimplyCoreAudio
import Combine
import UserNotifications

/// Service for managing audio output devices using CoreAudio
@Observable
final class AudioService {
    private let simplyCA = SimplyCoreAudio()
    private var cancellables = Set<AnyCancellable>()

    /// All available output devices
    private(set) var outputDevices: [AudioOutputDevice] = []

    /// Currently active output device
    private(set) var currentDevice: AudioOutputDevice?

    init() {
        refreshDevices()
        observeDeviceChanges()
        requestNotificationPermission()
    }

    /// Refresh the list of available output devices
    func refreshDevices() {
        let devices = simplyCA.allOutputDevices

        outputDevices = devices.compactMap { device -> AudioOutputDevice? in
            guard let uid = device.uid else { return nil }
            return AudioOutputDevice(
                objectID: device.id,
                uid: uid,
                name: device.name
            )
        }

        // Update current device
        if let defaultDevice = simplyCA.defaultOutputDevice,
           let uid = defaultDevice.uid {
            currentDevice = outputDevices.first { $0.uid == uid }
        } else {
            currentDevice = nil
        }
    }

    /// Set the default output device
    func setOutputDevice(_ device: AudioOutputDevice) {
        guard let scaDevice = simplyCA.allOutputDevices.first(where: { $0.uid == device.uid }) else {
            print("Device not found: \(device.name)")
            return
        }

        // Set this device as the default output device
        scaDevice.isDefaultOutputDevice = true

        // Verify the switch worked
        if simplyCA.defaultOutputDevice?.uid == device.uid {
            currentDevice = device
            showNotification(for: device)
        } else {
            print("Failed to set device: \(device.name)")
        }
    }

    /// Cycle to the next device in the selected devices list
    func cycleToNextDevice(in selectedDevices: [AudioOutputDevice]) {
        guard !selectedDevices.isEmpty else {
            print("No devices selected for cycling")
            return
        }

        // If only one device, just switch to it
        if selectedDevices.count == 1 {
            if let device = selectedDevices.first, device != currentDevice {
                setOutputDevice(device)
            }
            return
        }

        // Find current device in selected list
        guard let current = currentDevice else {
            // No current device, switch to first selected
            if let first = selectedDevices.first {
                setOutputDevice(first)
            }
            return
        }

        // Find current index and cycle to next
        if let currentIndex = selectedDevices.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % selectedDevices.count
            setOutputDevice(selectedDevices[nextIndex])
        } else {
            // Current device not in selected list, switch to first
            if let first = selectedDevices.first {
                setOutputDevice(first)
            }
        }
    }

    // MARK: - Private

    private func observeDeviceChanges() {
        NotificationCenter.default.publisher(for: .deviceListChanged)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshDevices()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .defaultOutputDeviceChanged)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshDevices()
            }
            .store(in: &cancellables)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func showNotification(for device: AudioOutputDevice) {
        let content = UNMutableNotificationContent()
        content.title = "Audio Output"
        content.body = "Switched to \(device.displayName)"
        content.sound = nil // Silent notification

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
}

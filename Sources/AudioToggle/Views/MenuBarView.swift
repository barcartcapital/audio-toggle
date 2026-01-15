import SwiftUI
import KeyboardShortcuts

/// Main menu bar popover content
struct MenuBarView: View {
    @Bindable var audioService: AudioService
    @Bindable var preferencesService: PreferencesService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Audio Output")
                    .font(.headline)
                Spacer()
                Button(action: { audioService.refreshDevices() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Refresh device list")
            }

            Divider()

            // Current device indicator
            if let current = audioService.currentDevice {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.green)
                    Text(current.displayName)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 2)
            } else {
                Text("No output device")
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Device selection
            Text("Cycle between:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if audioService.outputDevices.isEmpty {
                Text("No devices found")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(audioService.outputDevices) { device in
                    DeviceRow(
                        device: device,
                        isSelected: preferencesService.isSelected(device),
                        isCurrent: device == audioService.currentDevice,
                        onToggle: { preferencesService.toggleSelection(device) },
                        onSelect: { audioService.setOutputDevice(device) }
                    )
                }
            }

            Divider()

            // Hotkey configuration
            HStack {
                Text("Shortcut:")
                    .foregroundStyle(.secondary)
                Spacer()
                KeyboardShortcuts.Recorder(for: .cycleAudioDevice)
                    .frame(maxWidth: 150)
            }

            // Selected count indicator
            let selectedCount = preferencesService.selectedDeviceUIDs.count
            if selectedCount > 0 {
                Text("\(selectedCount) device\(selectedCount == 1 ? "" : "s") in cycle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Select devices above to cycle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Divider()

            // Footer actions
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                Text("v1.0.0")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .frame(width: 280)
    }
}

/// Row for a single device with selection toggle and quick-switch
struct DeviceRow: View {
    let device: AudioOutputDevice
    let isSelected: Bool
    let isCurrent: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Checkbox for cycle selection
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            // Device name - clickable to switch immediately
            Button(action: onSelect) {
                HStack {
                    Text(device.displayName)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if isCurrent {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    MenuBarView(
        audioService: AudioService(),
        preferencesService: PreferencesService()
    )
}

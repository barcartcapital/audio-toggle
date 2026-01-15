import Foundation
import CoreAudio

/// Represents an audio output device for the AudioToggle app
/// Named differently from SimplyCoreAudio's AudioDevice to avoid conflicts
struct AudioOutputDevice: Identifiable, Codable, Equatable, Hashable {
    let id: String          // Using UID as id for Identifiable conformance
    let objectID: UInt32    // CoreAudio AudioObjectID
    let uid: String         // Stable identifier across reconnections
    let name: String        // Device name from CoreAudio

    /// Cleaned up display name for UI
    var displayName: String {
        // Clean up common suffixes that add clutter
        var cleaned = name

        // Remove common suffixes
        let suffixesToRemove = [
            " - Front",
            " - Rear",
            " Audio",
            " Speakers"
        ]

        for suffix in suffixesToRemove {
            if cleaned.hasSuffix(suffix) && cleaned.count > suffix.count + 3 {
                cleaned = String(cleaned.dropLast(suffix.count))
            }
        }

        return cleaned
    }

    // Codable conformance using UID only (for persistence)
    enum CodingKeys: String, CodingKey {
        case uid
        case name
    }

    init(objectID: UInt32, uid: String, name: String) {
        self.id = uid
        self.objectID = objectID
        self.uid = uid
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = uid
        self.objectID = 0 // Will be resolved when matching with live devices
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(name, forKey: .name)
    }

    static func == (lhs: AudioOutputDevice, rhs: AudioOutputDevice) -> Bool {
        lhs.uid == rhs.uid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

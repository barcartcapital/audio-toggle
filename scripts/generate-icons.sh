#!/bin/bash
# Generate placeholder app icons for AudioToggle
# Replace these with proper branded icons later

ICON_DIR="Sources/AudioToggle/Assets.xcassets/AppIcon.appiconset"

# Create a simple placeholder icon using SF Symbols via Swift
# This creates a headphones icon as PNG files

swift << 'EOF'
import AppKit

let sizes = [16, 32, 64, 128, 256, 512, 1024]
let iconDir = "Sources/AudioToggle/Assets.xcassets/AppIcon.appiconset"

for size in sizes {
    let config = NSImage.SymbolConfiguration(pointSize: CGFloat(size) * 0.7, weight: .medium)

    guard let symbolImage = NSImage(systemSymbolName: "headphones", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else {
        print("Failed to create symbol for size \(size)")
        continue
    }

    // Create a new image with the exact size needed
    let finalImage = NSImage(size: NSSize(width: size, height: size))
    finalImage.lockFocus()

    // Fill with a gradient background
    let gradient = NSGradient(colors: [
        NSColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
    ])
    gradient?.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: -45)

    // Draw the symbol centered
    let symbolSize = symbolImage.size
    let x = (CGFloat(size) - symbolSize.width) / 2
    let y = (CGFloat(size) - symbolSize.height) / 2
    symbolImage.draw(at: NSPoint(x: x, y: y), from: .zero, operation: .sourceOver, fraction: 1.0)

    finalImage.unlockFocus()

    // Save as PNG
    guard let tiffData = finalImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for size \(size)")
        continue
    }

    let filename = "\(iconDir)/icon_\(size)x\(size).png"
    do {
        try pngData.write(to: URL(fileURLWithPath: filename))
        print("Created \(filename)")
    } catch {
        print("Failed to write \(filename): \(error)")
    }
}

print("Done! Now update Contents.json to reference the generated files.")
EOF

echo ""
echo "Icon generation complete!"
echo "Don't forget to update Contents.json with the filenames."

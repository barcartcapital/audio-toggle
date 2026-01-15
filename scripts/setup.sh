#!/bin/bash
set -e

echo "Setting up AudioToggle..."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode is required. Please install Xcode from the App Store."
    exit 1
fi

# Install xcodegen if not present
if ! command -v xcodegen &> /dev/null; then
    echo "Installing xcodegen..."
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
cd "$(dirname "$0")/.."
xcodegen generate

echo ""
echo "Setup complete! You can now:"
echo "  1. Open AudioToggle.xcodeproj in Xcode"
echo "  2. Build and run (Cmd+R)"
echo ""
echo "Or build from command line:"
echo "  xcodebuild -project AudioToggle.xcodeproj -scheme AudioToggle -configuration Release"

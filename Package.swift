// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioToggle",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "AudioToggle", targets: ["AudioToggle"])
    ],
    dependencies: [
        .package(url: "https://github.com/rnine/SimplyCoreAudio.git", from: "4.0.0"),
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AudioToggle",
            dependencies: [
                "SimplyCoreAudio",
                "KeyboardShortcuts"
            ],
            path: "Sources/AudioToggle",
            resources: [
                .process("../Resources")
            ]
        )
    ]
)

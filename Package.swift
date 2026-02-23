// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pluginn",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Pluginn", targets: ["PluginnApp"])
    ],
    targets: [
        .executableTarget(
            name: "PluginnApp",
            path: "Sources/PluginnApp"
        )
    ]
)

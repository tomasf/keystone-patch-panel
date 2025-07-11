// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "keystone-patch-panel",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/tomasf/Keystone.git", .upToNextMinor(from: "0.2.0"))
    ],
    targets: [
        .executableTarget(
            name: "keystone-patch-panel",
            dependencies: ["Cadova", "Keystone"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)

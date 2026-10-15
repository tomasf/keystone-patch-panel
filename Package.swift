// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "keystone-patch-panel",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", branch: "dev"),
        .package(url: "https://github.com/tomasf/Keystone.git", branch: "dev")
    ],
    targets: [
        .executableTarget(
            name: "keystone-patch-panel",
            dependencies: ["Cadova", "Keystone"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)

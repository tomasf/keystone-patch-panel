// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "keystone-patch-panel",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/tomasf/SwiftSCAD.git", from: "0.7.1"),
        .package(url: "https://github.com/tomasf/Keystone.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "keystone-patch-panel",
            dependencies: ["SwiftSCAD", "Keystone"]
        ),
    ]
)

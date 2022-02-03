// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [
        .macOS(.v10_14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", .exact("0.50500.0")),
    ],
    targets: [.target(name: "BuildTools", path: "")]
)

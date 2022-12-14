// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AUSScoreCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]),
        .library(
            name: "NewsFeature",
            targets: ["NewsFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.41.0"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "NewsFeature"
            ]),
        .target(
            name: "NewsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
    ]
)

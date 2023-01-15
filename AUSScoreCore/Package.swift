// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AUSScoreCore",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(
      name: "AUSClient",
      targets: ["AUSClient"]),
    .library(
      name: "AUSClientLive",
      targets: ["AUSClientLive"]),
    .library(
      name: "AppCore",
      targets: ["AppCore"]),
    .library(
      name: "NewsFeature",
      targets: ["NewsFeature"]),
    .library(
      name: "Models",
      targets: ["Models"]),
    .library(
      name: "DatabaseClient",
      targets: ["DatabaseClient"]),
    .library(
      name: "DatabaseClientLive",
      targets: ["DatabaseClientLive"]),
    .library(
      name: "AppCommon",
      targets: ["AppCommon"]),
    .library(
      name: "ScoresFeature",
      targets: ["ScoresFeature"]),

  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.41.0"),
    .package(url: "https://github.com/kean/Nuke", from: "11.4.0"),
    .package(url: "https://github.com/kean/Get", from: "2.1.0"),
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
    .package(url: "https://github.com/groue/SortedDifference", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AUSClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        "Models",
      ]),
    .target(
      name: "AUSClientLive",
      dependencies: [
        "AUSClient",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        "Models",
        "Get",
      ]),

    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "NewsFeature",
      ]),
    .target(
      name: "NewsFeature",
      dependencies: [
        "Models",
        "AUSClient",
        "AUSClientLive",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "NukeUI", package: "Nuke"),
        "AppCommon",
      ]),
    .target(
      name: "ScoresFeature",
      dependencies: [
        "Models",
        "AUSClient",
        "AUSClientLive",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "NukeUI", package: "Nuke"),
        "AppCommon",
      ]),
    .target(
      name: "Models",
      dependencies: []),
    .target(
      name: "DatabaseClient",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
      ]),
    .target(
      name: "DatabaseClientLive",
      dependencies: [
        "DatabaseClient",
        "Models",
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "Dependencies", package: "swift-composable-architecture"),
      ]),
    .target(
      name: "AppCommon",
      dependencies: []),
  ])

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AUSScoreCore",
  platforms: [.iOS(.v17)],
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
    .library(name: "BackgroundTask", targets: ["BackgroundTask"]),
    .library(name: "FavoritesFeature", targets: ["FavoritesFeature"]),
    .library(
      name: "ScoresFeature",
      targets: ["ScoresFeature"]),
    .library(name: "RemoteNotificationsClient", targets: ["RemoteNotificationsClient"]),
    .library(name: "UserNotificationsClient", targets: ["UserNotificationsClient"]),
    .library(name: "UserIdentifier", targets: ["UserIdentifier"]),
    .library(name: "AppNotificationsClient", targets: ["AppNotificationsClient"]),
    .library(name: "LeaguesFeature", targets: ["LeaguesFeature"]),
    .library(name: "GameFeature", targets: ["GameFeature"]),
    .library(name: "TeamFeature", targets: ["TeamFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
    .package(url: "https://github.com/kean/Nuke", from: "11.4.0"),
    .package(url: "https://github.com/kean/Get", from: "2.1.0"),
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
    .package(url: "https://github.com/groue/SortedDifference", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AUSClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Models",
      ]),
    .target(
      name: "AUSClientLive",
      dependencies: [
        "AUSClient",
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Models",
        "Get",
      ]),

    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "AUSClient",
        "DatabaseClient",
        "DatabaseClientLive",
        "NewsFeature",
        "ScoresFeature",
        "AppCommon",
        "RemoteNotificationsClient",
        "UserNotificationsClient",
        "Models",
        "UserIdentifier",
        "LeaguesFeature",
        "GameFeature",
        "TeamFeature",
        "FavoritesFeature"
      ]),
    .target(
      name: "NewsFeature",
      dependencies: [
        "Models",
        "AUSClient",
        "AUSClientLive",
        "DatabaseClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "NukeUI", package: "Nuke"),
        "AppCommon",
      ]),
    .target(name: "BackgroundTask", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
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
        "AppNotificationsClient",
        "GameFeature",
      ]),
    .target(name: "FavoritesFeature", dependencies: [
      "Models",
      "DatabaseClient",
      "AUSClient",
      "UserIdentifier",
      "AppCommon",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      .product(name: "NukeUI", package: "Nuke"),
    ]),
    .target(
      name: "Models",
      dependencies: []),
    .target(
      name: "DatabaseClient",
      dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]),
    .target(
      name: "DatabaseClientLive",
      dependencies: [
        "DatabaseClient",
        "Models",
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "SortedDifference", package: "SortedDifference"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]),
    .target(
      name: "AppCommon",
      dependencies: []),
    .target(name: "RemoteNotificationsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "UserNotificationsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "UserIdentifier", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "AppNotificationsClient", dependencies: [
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "LeaguesFeature", dependencies: [
      "Models",
      "DatabaseClient",
      "DatabaseClientLive",
      "AUSClient",
      "AppCommon",
      "UserIdentifier",
      "NewsFeature",
      "ScoresFeature",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GameFeature", dependencies: [
      "Models",
      "DatabaseClient",
      "AppCommon",
      .product(name: "NukeUI", package: "Nuke"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
    .target(name: "TeamFeature", dependencies: [
      "Models",
      "DatabaseClient",
      "AUSClient",
      "AppCommon",
      "UserIdentifier",
      .product(name: "NukeUI", package: "Nuke"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      .product(name: "Dependencies", package: "swift-dependencies"),
    ]),
  ])

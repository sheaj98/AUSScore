// Copyright © 2023 Shea Sullivan. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AUSClient: TestDependencyKey {
  public static let testValue = Self(
    newsFeeds: unimplemented("\(Self.self).newsFeeds"),
    newsItems: unimplemented("\(Self.self).newsItems"),
    schools: unimplemented("\(Self.self).schools"),
    sports: unimplemented("\(Self.self).sports"),
    teams: unimplemented("\(Self.self).teams"),
    allGames: unimplemented("\(Self.self).allGames"),
    gamesBySportId: unimplemented("\(Self.self).gamesBySportId"),
    bulkFetchGames: unimplemented("\(Self.self).bulkFetchGames"),
    gameResults: unimplemented("\(Self.self).gameResults"),
    upsertUser: unimplemented("\(Self.self).upsertUser"))

  public static let previewValue = Self(
    newsFeeds: { () in
      [.mock(id: 1), .mock(id: 2), .mock(id: 3)]
    },
    newsItems: { _ in
      [.mock(title: "Title1"), .mock(title: "Title2"), .mock(title: "Title3")]
    },
    schools: { () in
      [.unbMock()]
    },
    sports: { () in
      [.mock()]
    },
    teams: { () in
      [.mock()]
    },
    allGames: { () in
      [.mock(), .mock(), .mock()]
    },
    gamesBySportId: { _ in
      [.mock(), .mock(), .mock()]
    },
    bulkFetchGames: { _ in
      [.mock(), .mock(), .mock()]
    },
    gameResults: { () in
      [.mock(teamId: 12, gameId: "abc", isHome: true), .mock(teamId: 13, gameId: "abc123", isHome: false)]
    },
    upsertUser: { _ in
        return
    })
}

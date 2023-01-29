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
    gameResults: unimplemented("\(Self.self).gameResults"))

  public static let previewValue = Self(
    newsFeeds: { () in
      [.mock(id: "123"), .mock(id: "1234"), .mock(id: "12345")]
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
      [.mock(), .mock()]
    })
}

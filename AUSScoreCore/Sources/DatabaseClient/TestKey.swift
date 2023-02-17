// Copyright © 2023 Shea Sullivan. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DatabaseClient: TestDependencyKey {
  public static let testValue = Self(
    schools: unimplemented("\(Self.self).schools"),
    syncSchools: unimplemented("\(Self.self).syncSchools"),
    sports: unimplemented("\(Self.self).sports"),
    syncSports: unimplemented("\(Self.self).syncSports"),
    teams: unimplemented("\(Self.self).teams"),
    syncTeams: unimplemented("\(Self.self).syncTeams"),
    syncGames: unimplemented("\(Self.self).syncGames"),
    syncGameResults: unimplemented("\(Self.self).syncGameTeams"),
    gamesForDate: unimplemented("\(Self.self).gamesForDate"),
    datesWithGames: unimplemented("\(Self.self).datesWithGames"),
    gameStream: unimplemented("\(Self.self).gameStream"))
}

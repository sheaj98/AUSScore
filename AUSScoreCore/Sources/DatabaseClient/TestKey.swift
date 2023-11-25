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
    syncNewsFeed: unimplemented("\(Self.self).syncNewsFeed"),
    newsItemStream: unimplemented("\(Self.self).newsItemsStream"),
    gamesForDate: unimplemented("\(Self.self).gamesForDate"),
    datesWithGames: unimplemented("\(Self.self).datesWithGames"),
    gamesStream: unimplemented("\(Self.self).gamesStream"),
    syncNewsFeeds: unimplemented("\(Self.self).syncNewsFeeds"),
    gameStream: unimplemented("\(Self.self).gameStream"),
    gamesForTeam: unimplemented("\(Self.self).gamesForTeam"),
    teamsForSport: unimplemented("\(Self.self).teamsForSport"),
    syncUser: unimplemented("\(Self.self).syncUser"),
    userStream: unimplemented("\(Self.self).userStream"),
    addFavoriteSport: unimplemented("\(Self.self).addFavoriteTeam"),
    addFavoriteTeam: unimplemented("\(Self.self).addFavoriteTeam"),
    deleteFavoriteSport: unimplemented("\(Self.self).deleteFavoriteTeam"),
    deleteFavoriteTeam: unimplemented("\(Self.self).deleteFavoriteTeam"),
    conferenceSchools: unimplemented("\(Self.self).conferenceSchools")
  )
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import Combine
import Dependencies
import Foundation
import Models

// MARK: - DatabaseClient

public struct DatabaseClient {
  // MARK: Lifecycle

  public init(
    schools: @escaping @Sendable () async throws -> [School],
    syncSchools: @escaping @Sendable ([School]) async throws -> Void,
    sports: @escaping @Sendable () async throws -> [SportInfo],
    syncSports: @escaping @Sendable ([Sport]) async throws -> Void,
    teams: @escaping @Sendable () async throws -> [TeamInfo],
    syncTeams: @escaping @Sendable ([Team]) async throws -> Void,
    syncGames: @escaping @Sendable ([Game]) async throws -> Void,
    syncGameResults: @escaping @Sendable ([GameResult]) async throws -> Void,
    syncNewsFeed: @escaping @Sendable (Int64, [NewsItem]) async throws -> Void,
    newsItemStream: @escaping @Sendable (Int64) -> AsyncThrowingStream<[NewsItem], Error>,
    gamesForDate: @escaping @Sendable (Date) async throws -> [GameInfo],
    datesWithGames: @escaping @Sendable (Int64?) async throws -> [Date],
    gamesStream: @escaping @Sendable (Date, Int64?) -> AsyncThrowingStream<[GameInfo], Error>,
    syncNewsFeeds: @escaping @Sendable ([NewsFeed]) async throws -> Void,
    gameStream: @escaping @Sendable (String) -> AsyncThrowingStream<GameInfo, Error>,
    gamesForTeam: @escaping @Sendable (Int64) async throws -> [GameInfo],
    teamsForSport: @escaping @Sendable (Int64) async throws -> [TeamInfo],
    syncUser: @escaping @Sendable (UserResponse) async throws -> Void,
    userStream: @escaping @Sendable () -> AsyncThrowingStream<UserInfo, Error>,
    addFavoriteSport: @escaping @Sendable (Int64, String) async throws -> Void,
    addFavoriteTeam: @escaping @Sendable (Int64, String) async throws -> Void,
    deleteFavoriteSport: @escaping @Sendable (Int64, String) async throws -> Bool,
    deleteFavoriteTeam: @escaping @Sendable (Int64, String) async throws -> Bool,
    conferenceSchools: @escaping @Sendable () async throws -> [SchoolInfo]
  ) {
    self.schools = schools
    self.syncSchools = syncSchools
    self.sports = sports
    self.syncSports = syncSports
    self.teams = teams
    self.syncTeams = syncTeams
    self.syncGames = syncGames
    self.syncGameResults = syncGameResults
    self.syncNewsFeed = syncNewsFeed
    self.newsItemStream = newsItemStream
    self.gamesForDate = gamesForDate
    self.datesWithGames = datesWithGames
    self.gamesStream = gamesStream
    self.syncNewsFeeds = syncNewsFeeds
    self.gameStream = gameStream
    self.gamesForTeam = gamesForTeam
    self.teamsForSport = teamsForSport
    self.syncUser = syncUser
    self.userStream = userStream
    self.addFavoriteSport = addFavoriteSport
    self.addFavoriteTeam = addFavoriteTeam
    self.deleteFavoriteSport = deleteFavoriteSport
    self.deleteFavoriteTeam = deleteFavoriteTeam
    self.conferenceSchools = conferenceSchools
  }

  // MARK: Public

  public var schools: @Sendable () async throws -> [School]
  public var syncSchools: @Sendable ([School]) async throws -> Void
  public var sports: @Sendable () async throws -> [SportInfo]
  public var syncSports: @Sendable ([Sport]) async throws -> Void
  public var teams: @Sendable () async throws -> [TeamInfo]
  public var syncTeams: @Sendable ([Team]) async throws -> Void
  public var syncGames: @Sendable ([Game]) async throws -> Void
  public var syncGameResults: @Sendable ([GameResult]) async throws -> Void
  public var syncNewsFeed: @Sendable (Int64, [NewsItem]) async throws -> Void
  public var newsItemStream: @Sendable (Int64) -> AsyncThrowingStream<[NewsItem], Error>
  public var gamesForDate: @Sendable (Date) async throws -> [GameInfo]
  public var datesWithGames: @Sendable (Int64?) async throws -> [Date]
  public var gamesForTeam: @Sendable (Int64) async throws -> [GameInfo]
  public var gamesStream: @Sendable (Date, Int64?) -> AsyncThrowingStream<[GameInfo], Error>
  public var syncNewsFeeds: @Sendable ([NewsFeed]) async throws -> Void
  public var gameStream: @Sendable (String) -> AsyncThrowingStream<GameInfo, Error>
  public var teamsForSport: @Sendable (Int64) async throws -> [TeamInfo]
  public var syncUser: @Sendable (UserResponse) async throws -> Void
  public var userStream: @Sendable () -> AsyncThrowingStream<UserInfo, Error>
  public var addFavoriteSport: @Sendable (Int64, String) async throws -> Void
  public var addFavoriteTeam: @Sendable (Int64, String) async throws -> Void
  public var deleteFavoriteSport: @Sendable (Int64, String) async throws -> Bool
  public var deleteFavoriteTeam: @Sendable (Int64, String) async throws -> Bool
  public var conferenceSchools: @Sendable () async throws -> [SchoolInfo]
}

public extension DependencyValues {
  var databaseClient: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

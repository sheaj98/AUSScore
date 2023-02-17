// Copyright © 2023 Shea Sullivan. All rights reserved.

import Dependencies
import Foundation
import Combine
import Models

// MARK: - DatabaseClient

public struct DatabaseClient {
  // MARK: Lifecycle

  public init(
    schools: @escaping @Sendable () async throws -> [School],
    syncSchools: @escaping @Sendable ([School]) async throws -> Void,
    sports: @escaping @Sendable () async throws -> [Sport],
    syncSports: @escaping @Sendable ([Sport]) async throws -> Void,
    teams: @escaping @Sendable () async throws -> [TeamInfo],
    syncTeams: @escaping @Sendable ([Team]) async throws -> Void,
    syncGames: @escaping @Sendable ([Game]) async throws -> Void,
    syncGameResults: @escaping @Sendable ([GameResult]) async throws -> Void,
    gamesForDate: @escaping @Sendable (Date) async throws -> [GameInfo],
    datesWithGames: @escaping @Sendable () async throws -> [Date],
    gameStream: @escaping @Sendable (Date) -> AsyncThrowingStream<[GameInfo], Error>)
  {
    self.schools = schools
    self.syncSchools = syncSchools
    self.sports = sports
    self.syncSports = syncSports
    self.teams = teams
    self.syncTeams = syncTeams
    self.syncGames = syncGames
    self.syncGameResults = syncGameResults
    self.gamesForDate = gamesForDate
    self.datesWithGames = datesWithGames
    self.gameStream = gameStream
  }

  // MARK: Public

  public var schools: @Sendable () async throws -> [School]
  public var syncSchools: @Sendable ([School]) async throws -> Void
  public var sports: @Sendable () async throws -> [Sport]
  public var syncSports: @Sendable ([Sport]) async throws -> Void
  public var teams: @Sendable () async throws -> [TeamInfo]
  public var syncTeams: @Sendable ([Team]) async throws -> Void
  public var syncGames: @Sendable ([Game]) async throws -> Void
  public var syncGameResults: @Sendable ([GameResult]) async throws -> Void
  public var gamesForDate: @Sendable (Date) async throws -> [GameInfo]
  public var datesWithGames: @Sendable () async throws -> [Date]
  public var gameStream: @Sendable (Date) -> AsyncThrowingStream<[GameInfo], Error>
}

extension DependencyValues {
  public var databaseClient: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

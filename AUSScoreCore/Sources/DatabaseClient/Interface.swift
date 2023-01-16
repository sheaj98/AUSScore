// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
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
    syncTeams: @escaping @Sendable ([Team]) async throws -> Void)
  {
    self.schools = schools
    self.syncSchools = syncSchools
    self.sports = sports
    self.syncSports = syncSports
    self.teams = teams
    self.syncTeams = syncTeams
  }

  // MARK: Public

  public var schools: @Sendable () async throws -> [School]
  public var syncSchools: @Sendable ([School]) async throws -> Void
  public var sports: @Sendable () async throws -> [Sport]
  public var syncSports: @Sendable ([Sport]) async throws -> Void
  public var teams: @Sendable () async throws -> [TeamInfo]
  public var syncTeams: @Sendable ([Team]) async throws -> Void
}

extension DependencyValues {
  public var databaseClient: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

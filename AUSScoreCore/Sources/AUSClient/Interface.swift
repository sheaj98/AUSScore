// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import Models

// MARK: - APIClient

public struct AUSClient {
  public init(
    newsFeeds: @escaping @Sendable () async throws -> [NewsFeed],
    newsItems: @escaping @Sendable (_ newsFeedUrl: String) async throws -> [NewsItem],
    schools: @escaping @Sendable () async throws -> [School],
    sports: @escaping @Sendable () async throws -> [Sport],
    teams: @escaping @Sendable () async throws -> [Team],
    allGames: @escaping @Sendable () async throws -> [Game],
    gamesBySportId: @escaping @Sendable (_ sportId: String) async throws -> [Game],
    bulkFetchGames: @escaping @Sendable (_ gamesBulkDto: GamesBulkDTO) async throws -> [Game]
  ) {
    self.newsFeeds = newsFeeds
    self.newsItems = newsItems
    self.schools = schools
    self.sports = sports
    self.teams = teams
    self.allGames = allGames
    self.gamesBySportId = gamesBySportId
    self.bulkFetchGames = bulkFetchGames
  }

  // MARK: - News

  public var newsFeeds: @Sendable () async throws -> [NewsFeed]
  public var newsItems: @Sendable (_ newsFeedUrl: String) async throws -> [NewsItem]

  // MARK: - Schools

  public var schools: @Sendable () async throws -> [School]

  // MARK: - Sports

  public var sports: @Sendable () async throws -> [Sport]

  // MARK: - Teams

  public var teams: @Sendable () async throws -> [Team]

  // MARK: - Games

  public var allGames: @Sendable () async throws -> [Game]
  public var gamesBySportId: @Sendable (_ sportId: String) async throws -> [Game]
  public var bulkFetchGames: @Sendable (_ gamesBulkDTO: GamesBulkDTO) async throws -> [Game]
}

public extension DependencyValues {
  var ausClient: AUSClient {
    get { self[AUSClient.self] }
    set { self[AUSClient.self] = newValue }
  }
}

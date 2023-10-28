// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - Game

public struct Game: Identifiable, Equatable, Codable {
  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let currentTime: String?
  public let sportId: Int
  public let isExhibition: Bool
  public let is4PointGame: Bool
  public let isPlayoff: Bool

  public init(id: String, startTime: Date, status: GameStatus, currentTime: String?, sportId: Int, isExhibition: Bool = false, is4PointGame: Bool = false, isPlayoff: Bool = false) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sportId = sportId
    self.isExhibition = isExhibition
    self.is4PointGame = is4PointGame
    self.isPlayoff = isPlayoff
  }
}

// MARK: - GameStatus

public enum GameStatus: String, Codable {
  case complete = "COMPLETE"
  case inProgress = "IN_PROGRESS"
  case cancelled = "CANCELLED"
  case upcoming = "UPCOMING"
}

// MARK: - GamesBulkDTO

public struct GamesBulkDTO: Codable {
  public let gameIds: [String]

  public init(gameIds: [String]) {
    self.gameIds = gameIds
  }
}

// MARK: - Game Mock

extension Game {
  public static func mock() -> Self {
    .init(id: "f9kdp1vietzh2ub9", startTime: .now, status: .inProgress, currentTime: "3:32 4Q", sportId: 1)
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - Game

public struct Game: Identifiable, Equatable, Codable {
  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let gameTime: String?
  public let sportId: Int
  public let isExhibition: Bool
  public let isPlayoff: Bool
  public let description: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case startTime = "start_time"
    case status
    case gameTime = "game_time"
    case sportId = "sport_id"
    case isExhibition = "is_exhibition"
    case isPlayoff = "is_playoffs"
    case description
  }

  public init(id: String, startTime: Date, status: GameStatus, gameTime: String?, sportId: Int, isExhibition: Bool = false, isPlayoff: Bool = false, description: String? = nil) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.gameTime = gameTime
    self.sportId = sportId
    self.isExhibition = isExhibition
    self.isPlayoff = isPlayoff
    self.description = description
  }
}

// MARK: - GameStatus

public enum GameStatus: String, Codable {
  case complete = "COMPLETED"
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
    .init(id: "f9kdp1vietzh2ub9", startTime: .now, status: .inProgress, gameTime: "3:32 4Q", sportId: 1)
  }
}

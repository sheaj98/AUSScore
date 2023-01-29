//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-09.
//

import Foundation

// MARK: - Game Model

public struct Game: Identifiable, Equatable, Codable {
  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let currentTime: String?
  public let sportId: Int

  public init(id: String, startTime: Date, status: GameStatus, currentTime: String?, sportId: Int) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sportId = sportId
  }
}

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

public extension Game {
  static func mock() -> Self {
    return .init(id: "f9kdp1vietzh2ub9", startTime: .now, status: .inProgress, currentTime: "3:32 4Q", sportId: 1)
  }
}

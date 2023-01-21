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
  public let sportId: Int64
  public let homeGameResult: GameResult
  public let awayGameResult: GameResult

  public init(id: String, startTime: Date, status: GameStatus, currentTime: String?, sportId: Int64, homeGameResult: GameResult, awayGameResult: GameResult) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sportId = sportId
    self.homeGameResult = homeGameResult
    self.awayGameResult = awayGameResult
  }
}

public enum GameStatus: String, Codable {
  case complete = "COMPLETE"
  case inProgress = "IN_PROGRESS"
  case cancelled = "CANCELLED"
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
    return .init(id: "abc123", startTime: .now, status: .inProgress, currentTime: "2:33 4Q", sportId: 1, homeGameResult: .mock(), awayGameResult: .mock())
  }
}

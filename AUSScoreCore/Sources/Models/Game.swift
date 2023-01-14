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
  public let gameTeams: [GameTeam]

  public init(id: String, startTime: Date, status: GameStatus, gameTeams: [GameTeam]) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.gameTeams = gameTeams
  }

  enum CodingKeys: String, CodingKey {
    case id
    case startTime
    case status
    case gameTeams = "GameTeams"
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
    return .init(id: "f9kdp1vietzh2ub9", startTime: .now, status: .inProgress, gameTeams: [.mock(), .mock()])
  }
}

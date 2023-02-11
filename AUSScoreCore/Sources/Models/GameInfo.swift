// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

public struct GameInfo: Decodable {
  // MARK: Lifecycle

  public init(
    id: String,
    startTime: Date,
    status: GameStatus,
    currentTime: String?,
    sport: Sport,
    gameResults: [GameResultInfo])
  {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sport = sport
    self.gameResults = gameResults
  }

  // MARK: Public

  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let currentTime: String?
  public let sport: Sport
  public let gameResults: [GameResultInfo]
}

public extension GameInfo {
  static func mock(id: String,
                   startTime: Date = .now,
                   status: GameStatus = .upcoming,
                   sport: Sport = .mock(),
                   gameResults: [GameResultInfo] = [.mock(score: 12, isHome: true, gameId: "game1"), .mock(score: 32, isHome: false, gameId: "game1")]) -> Self
  {
    return .init(id: id, startTime: startTime, status: status, currentTime: nil, sport: sport, gameResults: gameResults)
  }
}

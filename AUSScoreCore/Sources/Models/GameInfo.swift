// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

public struct GameInfo: Decodable, Equatable {
  // MARK: Lifecycle

  public init(
    id: String,
    startTime: Date,
    status: GameStatus,
    currentTime: String?,
    sport: Sport,
    isExhibition: Bool = false,
    is4PointGame: Bool = false,
    gameResults: [GameResultInfo])
  {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sport = sport
    self.gameResults = gameResults
    self.isExhibition = isExhibition
    self.is4PointGame = is4PointGame
  }

  // MARK: Public

  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let currentTime: String?
  public let sport: Sport
  public let gameResults: [GameResultInfo]
  public let isExhibition: Bool
  public let is4PointGame: Bool
}

public extension GameInfo {
  static func mock(id: String,
                   startTime: Date = .now,
                   status: GameStatus = .upcoming,
                   sport: Sport = .mock(),
                   gameResults: [GameResultInfo] = [.mock(score: 12, isHome: true, team: .mock(id: 12, school: .unbMock(), sport: .mock()), gameId: "game1"), .mock(score: 32, isHome: false, gameId: "game1")]) -> Self
  {
    return .init(id: id, startTime: startTime, status: status, currentTime: nil, sport: sport, gameResults: gameResults)
  }
}

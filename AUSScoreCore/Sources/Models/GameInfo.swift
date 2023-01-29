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

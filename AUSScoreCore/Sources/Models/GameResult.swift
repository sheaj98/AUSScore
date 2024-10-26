// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - GameResult

public struct GameResult: Identifiable, Codable, Equatable {
  // MARK: Lifecycle

  public init(score: Int?, outcome: TeamOutcome, isHome: Bool, teamId: Int64, gameId: String) {
    self.score = score
    self.outcome = outcome
    self.isHome = isHome
    self.teamId = teamId
    self.gameId = gameId
  }

  // MARK: Public

  public let score: Int?
  public let outcome: TeamOutcome
  public let isHome: Bool
  public let teamId: Int64
  public let gameId: String

  public var id: String {
    "\(gameId)+\(teamId)"
  }
  
  enum CodingKeys: String, CodingKey {
    case score
    case outcome
    case isHome = "is_home"
    case teamId = "team_id"
    case gameId = "game_id"
  }

  // MARK: Internal

}

// MARK: - TeamOutcome

public enum TeamOutcome: String, Codable {
  case win = "WIN"
  case loss = "LOSS"
  case tbd = "TBD"
  case draw = "DRAW"
}

extension GameResult {
  public static func mock(teamId: Int64, gameId: String, isHome: Bool) -> Self {
    .init(score: 32, outcome: .loss, isHome: isHome, teamId: teamId, gameId: gameId)
  }
}

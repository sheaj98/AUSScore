//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-12.
//

import Foundation

public struct GameTeam: Identifiable, Codable, Equatable {
  public let score: Int
  public let outcome: TeamOutcome
  public let isHome: Bool
  public let teamId: UUID
  public let gameId: String

  public var id: String {
    "\(gameId)+\(teamId.uuidString)"
  }

  public init(score: Int, outcome: TeamOutcome, isHome: Bool, teamId: UUID, gameId: String) {
    self.score = score
    self.outcome = outcome
    self.isHome = isHome
    self.teamId = teamId
    self.gameId = gameId
  }
}

public enum TeamOutcome: String, Codable {
  case win = "WIN"
  case loss = "LOSS"
  case tbd = "TBD"
  case draw = "DRAW"
}

public extension GameTeam {
  static func mock() -> Self {
    return .init(score: 32, outcome: .loss, isHome: true, teamId: UUID(), gameId: "f9kdp1vietzh2ub9")
  }
}

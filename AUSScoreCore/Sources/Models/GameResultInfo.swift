//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-12.
//

import Foundation

public struct GameResultInfo: Decodable, Equatable {
  public let score: Int?
  public let outcome: TeamOutcome
  public let isHome: Bool
  public let team: TeamInfo
  public let gameId: String

  public init(score: Int?, outcome: TeamOutcome, isHome: Bool, team: TeamInfo, gameId: String) {
    self.score = score
    self.outcome = outcome
    self.isHome = isHome
    self.team = team
    self.gameId = gameId
  }
  
  enum CodingKeys: String, CodingKey {
    case score
    case outcome
    case isHome = "home"
    case team
    case gameId
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

public struct GameResultInfo: Decodable, Equatable {
  // MARK: Lifecycle

  public init(score: Int?, outcome: TeamOutcome, isHome: Bool, team: TeamInfo, gameId: String) {
    self.score = score
    self.outcome = outcome
    self.isHome = isHome
    self.team = team
    self.gameId = gameId
  }

  // MARK: Public

  public let score: Int?
  public let outcome: TeamOutcome
  public let isHome: Bool
  public var team: TeamInfo
  public let gameId: String

  // MARK: Internal
  enum CodingKeys: String, CodingKey {
    case score
    case outcome
    case isHome = "is_home"
    case team
    case gameId = "game_id"
  }

}

public extension GameResultInfo {
  static func mock(score: Int?, outcome: TeamOutcome = .tbd, isHome: Bool, team: TeamInfo = .mock(id: 1, school: .stfxMock(), sport: .mock()), gameId: String) -> Self {
    return .init(score: score, outcome: outcome, isHome: isHome, team: team, gameId: gameId)
  }
  
  static func unknown(outcome: TeamOutcome = .tbd, isHome: Bool, team: TeamInfo = .init(id: 0, school: .init(id: 0, name: "Unknown", location: "Unknown", logo: nil, displayName: "Unknown"), sport: .mock(), record: nil), gameId: String) -> Self {
    return .init(score: nil, outcome: outcome, isHome: isHome, team: team, gameId: gameId)
  }
}

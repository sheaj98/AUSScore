// Copyright © 2023 Solbits Software Inc. All rights reserved.

import GRDB
import Models

// MARK: - GameResult + FetchableRecord, PersistableRecord

extension GameResult: FetchableRecord, PersistableRecord {}

extension GameResult {
  static let game = belongsTo(Game.self)
  static let team = belongsTo(Team.self)
  
  var game: QueryInterfaceRequest<Game> {
    request(for: GameResult.game)
  }
  
  var team: QueryInterfaceRequest<Team> {
    request(for: GameResult.team)
  }
}

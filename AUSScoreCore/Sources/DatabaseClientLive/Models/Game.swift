// Copyright © 2023 Shea Sullivan. All rights reserved.

import GRDB
import Models

// MARK: - Game + FetchableRecord, PersistableRecord

extension Game: FetchableRecord, PersistableRecord { }

extension Game {
  static let sport = belongsTo(Sport.self)
  static let gameResults = hasMany(GameResult.self)

  var sport: QueryInterfaceRequest<Sport> {
    request(for: Game.sport)
  }

  var gameResults: QueryInterfaceRequest<GameResult> {
    request(for: Game.gameResults)
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import GRDB
import Models

// MARK: - GameResult + FetchableRecord, PersistableRecord

extension GameResult: FetchableRecord, PersistableRecord { }

extension GameResult {
  public static var databaseTableName: String {
    "game_result"
  }
  static let game = belongsTo(Game.self)
  static let team = belongsTo(Team.self)

  var game: QueryInterfaceRequest<Game> {
    request(for: GameResult.game)
  }

  var team: QueryInterfaceRequest<Team> {
    request(for: GameResult.team)
  }
}

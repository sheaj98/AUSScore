// Copyright © 2023 Shea Sullivan. All rights reserved.

import GRDB
import Models

// MARK: - Team + FetchableRecord, PersistableRecord

extension Team: FetchableRecord, PersistableRecord { }

extension Team {
  static let sport = belongsTo(Sport.self)
  static let school = belongsTo(School.self)
  static let gameResults = hasMany(GameResult.self)
  
  
  
  var sport: QueryInterfaceRequest<Sport> {
    request(for: Team.sport)
  }

  var school: QueryInterfaceRequest<School> {
    request(for: Team.school)
  }
  
  var gameResults: QueryInterfaceRequest<GameResult> {
    request(for: Team.gameResults)
  }
}

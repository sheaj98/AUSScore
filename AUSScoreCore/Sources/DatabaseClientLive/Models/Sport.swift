// Copyright © 2023 Shea Sullivan. All rights reserved.

import GRDB
import Models

// MARK: - Sport + FetchableRecord, PersistableRecord

extension Sport: FetchableRecord, PersistableRecord { }

extension Sport {
  static let teams = hasMany(Team.self)
  static let games = hasMany(Game.self)
  static let newsfeed = belongsTo(NewsFeed.self)
  
  var newsfeed: QueryInterfaceRequest<NewsFeed> {
    request(for: Sport.newsfeed)
  }

  var teams: QueryInterfaceRequest<Team> {
    request(for: Sport.teams)
  }

  var games: QueryInterfaceRequest<Game> {
    request(for: Sport.games)
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import GRDB
import Models

// MARK: - School + FetchableRecord, PersistableRecord

extension School: FetchableRecord, PersistableRecord { }

extension School {
  static let teams = hasMany(Team.self)

  var teams: QueryInterfaceRequest<Team> {
    request(for: School.teams)
  }
}

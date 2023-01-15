// Copyright © 2023 Solbits Software Inc. All rights reserved.

import GRDB
import Models

// MARK: - Sport + FetchableRecord, PersistableRecord

extension Sport: FetchableRecord, PersistableRecord { }

extension Sport {
  static let teams = hasMany(Team.self)

  var teams: QueryInterfaceRequest<Team> {
    request(for: Sport.teams)
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import DatabaseClient
import Dependencies
import Foundation
import GRDB
import Models
import SortedDifference

extension DatabaseClient: DependencyKey {
  // MARK: Public

  public static var liveValue = Self.live()

  // MARK: Internal

  static func live() -> Self {
    func dbWriter() -> DatabasePool {
      do {
        let db = try Self.createDatabase()
        try Self.registerMigrations(for: db)
        return db
      } catch {
        fatalError("Could not create database \(error)")
      }
    }

    let dbWriter = dbWriter()

    return Self(
      schools: {
        try await dbWriter.read { db in
          try School.all().fetchAll(db)
        }
      },
      syncSchools: { schools in
        try dbWriter.write { db in
          let localSchools = try School.all()
            .order(Column("id"))
            .fetchAll(db)

          let remoteSchools = schools.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localSchools,
            identifiedBy: { $0.id },
            right: remoteSchools,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try local.updateChanges(db, from: remote)
            }
          }
        }
      },
      sports: {
        try await dbWriter.read { db in
          try Sport.all().fetchAll(db)
        }
      },
      syncSports: { sports in
        try dbWriter.write { db in
          let localSports = try Sport.all()
            .order(Column("id"))
            .fetchAll(db)

          let remoteSports = sports.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localSports,
            identifiedBy: { $0.id },
            right: remoteSports,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try local.updateChanges(db, from: remote)
            }
          }
        }
      },
      teams: {
        try await dbWriter.read { db in
          try Team
            .including(required: Team.sport)
            .including(required: Team.school)
            .select(Column("id"), as: Int64.self)
            .asRequest(of: TeamInfo.self)
            .fetchAll(db)
        }
      },
      syncTeams: { teams in
        try dbWriter.write { db in
          let localTeams = try Team.all()
            .order(Column("id"))
            .fetchAll(db)

          let remoteTeams = teams.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localTeams,
            identifiedBy: { $0.id },
            right: remoteTeams,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try local.updateChanges(db, from: remote)
            }
          }
        }
      },
      syncGames: { games in
        try dbWriter.write { db in
          let localGames = try Game.all()
            .order(Column("id"))
            .fetchAll(db)

          let remoteGames = games.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localGames,
            identifiedBy: { $0.id },
            right: remoteGames,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try local.updateChanges(db, from: remote)
            }
          }
        }
      },
      syncGameResults: { gameResults in
        try dbWriter.write { db in
          var localGames = try GameResult.all()
            .order(Column("gameId"), Column("teamId"))
            .fetchAll(db)

          localGames = localGames.sorted(by: { $0.id < $1.id })

          let remoteGames = gameResults.sorted(by: { $0.id < $1.id })
          let mergeSteps = SortedDifference(
            left: localGames,
            identifiedBy: { $0.id },
            right: remoteGames,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try local.updateChanges(db, from: remote)
            }
          }
        }
      },
      gamesForDate: { selectedDate in
        try await dbWriter.read { db in

          try Game
            .including(
              all: Game.gameResults
                .including(
                  required: GameResult.team
                    .including(required: Team.school)
                    .including(required: Team.sport)))
            .including(required: Game.sport)
            .filter(
              selectedDate < Column("startTime") && Column("startTime") < Calendar.current
                .date(byAdding: .day, value: 1, to: selectedDate))
            .asRequest(of: GameInfo.self)
            .fetchAll(db)
        }
      },
      datesWithGames: {
        try await dbWriter.read { db in
          let dates = try Game
            .select(Column("startTime"), as: Date.self)
            .distinct()
            .fetchAll(db)

          let startOfDays = dates.map(\.startOfDay)
          return Array(Set(startOfDays)).sorted(by: { $0 < $1 })
        }
      })
  }

  // MARK: Private

  private static func createDatabase() throws -> DatabasePool {
    let dbDirectory = URL.documentsDirectory.appendingPathComponent("Database")
    try FileManager.default.createDirectory(at: dbDirectory, withIntermediateDirectories: true)
    let dbUrl = dbDirectory.appendingPathComponent("db.sqlite")
    return try DatabasePool(path: dbUrl.path)
  }

  private static func registerMigrations(for db: DatabasePool) throws {
    var migrator = DatabaseMigrator()

    #if DEBUG
    // Speed up development by nuking the database when migrations change
    // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
    migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("createSchool") { db in
      try db.create(table: "school") { t in
        t.primaryKey("id", .integer)
        t.column("name", .text).notNull()
        t.column("location", .text).notNull()
        t.column("logo", .text)
        t.column("displayName", .text).notNull()
      }
    }

    migrator.registerMigration("createSport") { db in
      try db.create(table: "sport") { t in
        t.primaryKey("id", .integer)
        t.column("name", .text).notNull()
        t.column("gender", .text).notNull()
      }
    }

    migrator.registerMigration("createTeam") { db in
      try db.create(table: "team") { t in
        t.primaryKey("id", .integer)
        t.column("schoolId", .integer)
          .notNull()
          .indexed()
          .references("school", onDelete: .cascade)

        t.column("sportId", .integer)
          .notNull()
          .indexed()
          .references("sport", onDelete: .cascade)
      }
    }

    migrator.registerMigration("createGame") { db in
      try db.create(table: "game") { t in
        t.primaryKey("id", .text)

        t.column("startTime", .datetime)
          .notNull()
          .indexed()

        t.column("status", .text)
          .notNull()

        t.column("currentTime", .text)

        t.column("sportId", .integer)
          .notNull()
          .indexed()
          .references("sport", onDelete: .cascade)
      }
    }

    migrator.registerMigration("createGameResult") { db in
      try db.create(table: "gameResult") { t in
        t.column("score", .integer)
        t.column("outcome", .text)
        t.column("home", .boolean)
        t.column("teamId", .integer)
          .notNull()
          .indexed()
          .references("team", onDelete: .cascade)
        t.column("gameId", .text)
          .notNull()
          .indexed()
          .references("game", onDelete: .cascade)

        t.primaryKey(["gameId", "teamId"])
      }
    }

    try migrator.migrate(db)
  }
}

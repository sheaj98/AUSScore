// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import Combine
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

    let gamesDidChange: AnyPublisher<Void, Error> = DatabaseRegionObservation(tracking: Game.all(), GameResult.all())
      .publisher(in: dbWriter)
      .map { _ in }
      .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
      .share()
      .eraseToAnyPublisher()

    let newsItemsDidChange: AnyPublisher<Void, Error> = DatabaseRegionObservation(tracking: NewsItem.all())
      .publisher(in: dbWriter)
      .map { _ in }
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .share()
      .eraseToAnyPublisher()

    let userDidChange: AnyPublisher<Void, Error> = DatabaseRegionObservation(tracking: [User.all(), FavoriteTeam.all(), FavoriteSport.all()])
      .publisher(in: dbWriter)
      .map { _ in }
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .share()
      .eraseToAnyPublisher()

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
              try remote.updateChanges(db, from: local)
            }
          }
        }
      },
      sports: {
        try await dbWriter.read { db in
          try Sport.all().order(Column("name"))
            .including(optional: Sport.newsfeed)
            .asRequest(of: SportInfo.self)
            .fetchAll(db)
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
              try remote.updateChanges(db, from: local)
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
              try remote.updateChanges(db, from: local)
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
              try remote.updateChanges(db, from: local)
            }
          }
        }
      },
      syncGameResults: { gameResults in
        try dbWriter.write { db in
          var localGames = try GameResult.all()
            .order(Column("game_id"), Column("team_id"))
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
              try remote.updateChanges(db, from: local)
            }
          }
        }
      },
      syncNewsFeed: { newsFeedId, newsItems in
        try dbWriter.write { db in
          let localNewsItems = try NewsItem.joining(required: NewsItem.newsFeeds.filter(Column("id") == newsFeedId)).order(Column("id")).fetchAll(db)

          let remoteNewsItems = newsItems.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localNewsItems,
            identifiedBy: { $0.id },
            right: remoteNewsItems,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db, onConflict: .ignore)
              let newsFeedCategory = NewsFeedCategory(newsFeedId: newsFeedId, newsItemId: remote.id)
              try newsFeedCategory.insert(db)
            case .common(let local, let remote):
              try remote.updateChanges(db, from: local)
            }
          }
        }
      },
      newsItemStream: { newsFeedId in
        newsItemsDidChange
          .prepend(())
          .map { [dbWriter] in
            dbWriter.readPublisher { db in
              try NewsItem.joining(required: NewsItem.newsFeeds.filter(Column("id") == newsFeedId)).order(Column("date").desc).fetchAll(db)
            }
          }
          .switchToLatest()
          .eraseToAnyPublisher()
          .values
          .eraseToThrowingStream()
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
            .filter((selectedDate.startOfDay...selectedDate.endOfDay).contains(Column("start_time")))
            .asRequest(of: GameInfo.self)
            .fetchAll(db)
        }
      },
      datesWithGames: { sportId in
        try await dbWriter.read { db in
          var query = Game
            .select(Column("start_time"), as: Date.self)
            .distinct()

          if let sportId = sportId {
            query = query.filter(Column("sport_id") == sportId)
          }

          let dates = try query.fetchAll(db)

          let startOfDays = dates.map(\.startOfDay)
          return Array(Set(startOfDays)).sorted(by: { $0 < $1 })
        }
      },

      gamesStream: { date, sportId in
        gamesDidChange
          .prepend(())
          .map { [dbWriter] in
            dbWriter.readPublisher { db in
              let start = date.startOfDay
              let end = date.endOfDay

              var query = Game
                .including(
                  all: Game.gameResults
                    .including(
                      required: GameResult.team
                        .including(required: Team.school)
                        .including(required: Team.sport)))
                .including(required: Game.sport)
                .filter((start...end).contains(Column("start_time")))
                .asRequest(of: GameInfo.self)

              if let sportId = sportId {
                query = query.filter(Column("sport_id") == sportId)
              }

              return try query.fetchAll(db)
            }
          }
          .switchToLatest()
          .eraseToAnyPublisher()
          .values
          .eraseToThrowingStream()
      },
      syncNewsFeeds: { newsFeeds in
        try dbWriter.write { db in
          let localNewsFeeds = try NewsFeed.all().order(Column("id")).fetchAll(db)

          let remoteNewsFeeds = newsFeeds.sorted(by: { $0.id < $1.id })

          let mergeSteps = SortedDifference(
            left: localNewsFeeds,
            identifiedBy: { $0.id },
            right: remoteNewsFeeds,
            identifiedBy: { $0.id })
          for mergeStep in mergeSteps {
            switch mergeStep {
            case .left(let local):
              try local.delete(db)
            case .right(let remote):
              try remote.insert(db)
            case .common(let local, let remote):
              try remote.updateChanges(db, from: local)
            }
          }
        }
      },
      gameStream: { gameId in
        gamesDidChange
          .prepend(())
          .map { [dbWriter] in
            dbWriter.readPublisher { db in

              let query = Game
                .including(
                  all: Game.gameResults
                    .including(
                      required: GameResult.team
                        .including(required: Team.school)
                        .including(required: Team.sport)))
                .including(required: Game.sport)
                .filter(Column("id") == gameId)
                .asRequest(of: GameInfo.self)

              var game = try query.fetchOne(db)!
              let team0Record = try GameResult.filter(Column("team_id") == game.gameResults[0].team.id)
                .joining(required: GameResult.game.filter(Column("is_exhibition") == false).filter(Column("is_playoffs") == false))
                .fetchAll(db)
                .reduce((0, 0, 0)) { partialResult, gameResult in
                  let (wins, losses, draw) = partialResult
                  switch gameResult.outcome {
                  case .win:
                    return (wins + 1, losses, draw)
                  case .loss:
                    return (wins, losses + 1, draw)
                  case .draw:
                    return (wins, losses, draw + 1)
                  case .tbd:
                    return (wins, losses, draw)
                  }
                }

              let team1Record = try GameResult.filter(Column("team_id") == game.gameResults[1].team.id)
                .joining(required: GameResult.game.filter(Column("is_exhibition") == false).filter(Column("is_playoffs") == false))
                .fetchAll(db)
                .reduce((0, 0, 0)) { partialResult, gameResult in
                  let (wins, losses, draw) = partialResult
                  switch gameResult.outcome {
                  case .win:
                    return (wins + 1, losses, draw)
                  case .loss:
                    return (wins, losses + 1, draw)
                  case .draw:
                    return (wins, losses, draw + 1)
                  case .tbd:
                    return (wins, losses, draw)
                  }
                }

              game.gameResults[0].team.record = TeamInfo.GameRecord(wins: team0Record.0, losses: team0Record.1, draws: team0Record.2)

              game.gameResults[1].team.record = TeamInfo.GameRecord(wins: team1Record.0, losses: team1Record.1, draws: team1Record.2)

              return game
            }
          }
          .switchToLatest()
          .eraseToAnyPublisher()
          .values
          .eraseToThrowingStream()
      },
      gamesForTeam: { teamId in
        try await dbWriter.read { db in
          let games = try Game
            .order(Column("start_time").asc)
            .including(
              all: Game.gameResults
                .including(
                  required: GameResult.team
                    .including(required: Team.school)
                    .including(required: Team.sport)))
            .including(required: Game.sport)
            .asRequest(of: GameInfo.self)
            .fetchAll(db)

          return games.filter { game in
            game.gameResults.contains { $0.team.id == teamId }
          }
        }
      },
      teamsForSport: { sportId in
        try await dbWriter.read { db in
          let teams = try Team.all()
            .filter(Column("sport_id") == sportId)
            .filter(Column("is_conference") == true)
            .including(required: Team.sport)
            .including(required: Team.school)
            .asRequest(of: TeamInfo.self)
            .fetchAll(db)
            .map { team in
              var newTeam = team
              let record = try GameResult.filter(Column("team_id") == team.id)
                .joining(required: GameResult.game.filter(Column("is_exhibition") == false).filter(Column("is_playoffs") == false))
                .fetchAll(db)
                .reduce((0, 0, 0)) { partialResult, gameResult in
                  let (wins, losses, draw) = partialResult
                  switch gameResult.outcome {
                  case .win:
                    return (wins + 1, losses, draw)
                  case .loss:
                    return (wins, losses + 1, draw)
                  case .draw:
                    return (wins, losses, draw + 1)
                  case .tbd:
                    return (wins, losses, draw)
                  }
                }
              newTeam.record = TeamInfo.GameRecord(wins: record.0, losses: record.1, draws: record.2)
              return newTeam
            }

          return teams
        }
      }, syncUser: { user in
        try await dbWriter.write { db in
          if let _ = try? User.find(db, key: user.id) {} else {
            // Create the user if it doesn't exist
            try User(id: user.id).insert(db, onConflict: .abort)
          }
          try user.favoriteTeams.forEach { teamId in
            try FavoriteTeam(userId: user.id, teamId: Int64(teamId)).insert(db, onConflict: .ignore)
          }

          try user.favoriteSports.forEach { sportId in
            try FavoriteSport(userId: user.id, sportId: Int64(sportId)).insert(db, onConflict: .ignore)
          }
        }
      },
      userStream: {
        userDidChange
          .prepend(())
          .map { [dbWriter] in
            dbWriter.readPublisher { db in
              let user = try User.including(all:
                User.favoriteSports
                  .including(required: Sport.newsfeed)
                  .forKey("favorite_sports"))
                .including(all: User.favoriteTeams
                  .including(required: Team.sport)
                  .including(required: Team.school)
                  .forKey("favorite_teams")
                )
                .asRequest(of: UserInfo.self)
                .fetchOne(db)
              return user
            }
          }
          .switchToLatest()
          .compactMap { $0 }
          .eraseToAnyPublisher()
          .values
          .eraseToThrowingStream()
      },
      addFavoriteSport: { sportId, userId in
        try await dbWriter.write { db in
          try FavoriteSport(userId: userId, sportId: sportId).insert(db)
        }
      },
      addFavoriteTeam: { teamId, userId in
        try await dbWriter.write { db in
          try FavoriteTeam(userId: userId, teamId: teamId).insert(db)
        }
      },
      deleteFavoriteSport: { sportId, userId in
        try await dbWriter.write { db in
          let res = try FavoriteSport.deleteOne(db, key: ["user_id": userId, "sport_id": sportId])
          return res
        }
      },
      deleteFavoriteTeam: { teamId, userId in
        try await dbWriter.write { db in
          try FavoriteTeam.deleteOne(db, key: ["user_id": userId, "team_id": teamId])
        }
      },
      conferenceSchools: {
        try await dbWriter.read { db in
          try School.all().including(all: School.teams
            .filter(Column("is_conference") == true)
            .including(required: Team.sport)
            .including(required: Team.school)
          )
          .order(Column("display_name"))
          .asRequest(of: SchoolInfo.self).fetchAll(db)
          .filter {
            !$0.teams.isEmpty
          }
        }
      }
    )
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

    migrator.registerMigration("create_school") { db in
      try db.create(table: "school") { t in
        t.primaryKey("id", .integer)
        t.column("name", .text).notNull()
        t.column("location", .text).notNull()
        t.column("logo", .text)
        t.column("display_name", .text).notNull()
      }
    }

    migrator.registerMigration("create_newsfeed") { db in
      try db.create(table: "newsfeed", body: { t in
        t.primaryKey("id", .integer)
        t.column("display_name", .text)
        t.column("url", .text)
      })
    }

    migrator.registerMigration("createSport") { db in
      try db.create(table: "sport") { t in
        t.primaryKey("id", .integer)
        t.column("name", .text).notNull()
        t.column("gender", .text).notNull()
        t.column("icon", .text)
        t.column("win_value", .integer)

        t.column("newsfeed_id", .integer)
          .notNull()
          .indexed()
          .references("newsfeed")
      }
    }

    migrator.registerMigration("create_team") { db in
      try db.create(table: "team") { t in
        t.primaryKey("id", .integer)
        t.column("is_conference", .boolean).defaults(to: false)
        t.column("school_id", .integer)
          .notNull()
          .indexed()
          .references("school", onDelete: .cascade)

        t.column("sport_id", .integer)
          .notNull()
          .indexed()
          .references("sport", onDelete: .cascade)
      }
    }

    migrator.registerMigration("create_game") { db in
      try db.create(table: "game") { t in
        t.primaryKey("id", .text)

        t.column("start_time", .datetime)
          .notNull()
          .indexed()

        t.column("status", .text)
          .notNull()

        t.column("current_time", .text)
        t.column("is_exhibition", .boolean)
        t.column("is_playoffs", .boolean)
        t.column("description", .text)

        t.column("sport_id", .integer)
          .notNull()
          .indexed()
          .references("sport", onDelete: .cascade)
      }
    }

    migrator.registerMigration("create_user") { db in
      try db.create(table: "user") { t in
        t.primaryKey("id", .text)
      }
    }
    
    migrator.registerMigration("create_favorite_teams") { db in
      try db.create(table: "favorite_team") { t in
        t.column("team_id", .integer)
          .notNull()
          .references("team", onDelete: .cascade)

        t.column("user_id", .text)
          .notNull()
          .indexed()
          .references("user", onDelete: .cascade)

        t.primaryKey(["user_id", "team_id"])
      }
    }

    migrator.registerMigration("create_favorite_sports") { db in
      try db.create(table: "favorite_sport") { t in
        t.column("sport_id", .integer)
          .notNull()
          .references("sport", onDelete: .cascade)

        t.column("user_id", .text)
          .notNull()
          .indexed()
          .references("user", onDelete: .cascade)

        t.primaryKey(["user_id", "sport_id"])
      }
    }

    migrator.registerMigration("create_game_result") { db in
      try db.create(table: "game_result") { t in
        t.column("score", .integer)
        t.column("outcome", .text)
        t.column("is_home", .boolean)
        t.column("team_id", .integer)
          .notNull()
          .indexed()
          .references("team", onDelete: .cascade)
        t.column("game_id", .text)
          .notNull()
          .indexed()
          .references("game", onDelete: .cascade)

        t.primaryKey(["game_id", "team_id"])
      }
    }

    migrator.registerMigration("create_news_items") { db in
      try db.create(table: "news_item", body: { t in
        t.column("title", .text)
        t.column("link", .text)
        t.column("content", .text)
        t.column("image_url", .text)
        t.column("date", .datetime)
        t.primaryKey("id", .text)
      })
    }

    migrator.registerMigration("create_news_item_categories") { db in
      try db.create(table: "newsfeed_category", body: { t in
        t.column("newsfeed_id", .integer)
          .notNull()
          .indexed()
          .references("newsfeed", onDelete: .cascade)
        t.column("news_item_id", .text)
          .notNull()
          .indexed()
          .references("news_item", onDelete: .cascade)
      })
    }

    try migrator.migrate(db)
  }
}

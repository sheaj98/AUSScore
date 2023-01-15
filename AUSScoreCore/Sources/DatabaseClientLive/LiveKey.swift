// Copyright © 2023 Solbits Software Inc. All rights reserved.

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

    try migrator.migrate(db)
  }
}

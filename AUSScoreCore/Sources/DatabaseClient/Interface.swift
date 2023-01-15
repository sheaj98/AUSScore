// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import Models

public struct DatabaseClient {
  // MARK: Lifecycle

  public var schools: () async throws -> [School]

  public init(schools: @escaping () async throws -> [School]) {
    self.schools = schools
  }
}

extension DependencyValues {
  public var databaseClient: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

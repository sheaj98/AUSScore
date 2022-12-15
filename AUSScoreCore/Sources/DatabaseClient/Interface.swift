// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import Models

public struct DatabaseClient {
  // MARK: Lifecycle

  public var newsItems: () async throws -> [NewsItem]

  public init(newsItems: @escaping () async throws -> [NewsItem]) {
    self.newsItems = newsItems
  }
}

extension DependencyValues {
  public var databaseClient: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

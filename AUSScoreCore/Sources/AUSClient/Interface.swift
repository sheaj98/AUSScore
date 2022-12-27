// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import Models

// MARK: - APIClient

public struct AUSClient {
  public init(
    newsFeeds: @escaping @Sendable () async throws -> [NewsFeed],
    newsItems: @escaping @Sendable () async throws -> [NewsItem])
  {
    self.newsFeeds = newsFeeds
    self.newsItems = newsItems
  }

  public var newsFeeds: @Sendable () async throws -> [NewsFeed]
  public var newsItems: @Sendable () async throws -> [NewsItem]
}

extension DependencyValues {
  public var ausClient: AUSClient {
    get { self[AUSClient.self] }
    set { self[AUSClient.self] = newValue }
  }
}

// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import Models

// MARK: - APIClient

public struct APIClient {
  public init(
    topNews: @escaping @Sendable () async throws -> [NewsItem])
  {
    self.topNews = topNews
  }

  public var topNews: @Sendable () async throws -> [NewsItem]
}

extension DependencyValues {
  public var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}

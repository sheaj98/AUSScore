// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import Dependencies
import Foundation
import Models
import Get

extension AUSClient: DependencyKey {
  public static let liveValue = live()

  private static func live() -> Self {
    
    let client = APIClient(baseURL: URL(string: "https://aus-sports-api-production.up.railway.app"))
    
    return Self(
      newsFeeds: {
        let request = Request<[NewsFeed]>(path: "newsfeeds")
        return try await client.send(request).value
      }
    )
  }
}

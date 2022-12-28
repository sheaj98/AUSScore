// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import Dependencies
import Foundation
import Get
import Models

// MARK: - AUSClient + DependencyKey

extension AUSClient: DependencyKey {
  // MARK: Public

  public static let liveValue = live()

  // MARK: Private

  private static func live() -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601TimeZone)

    let client = APIClient(baseURL: URL(string: "https://aus-sports-api-production.up.railway.app")) {
      $0.decoder = decoder
    }

    return Self(
      newsFeeds: {
        let request = Request<[NewsFeed]>(path: "newsfeeds")
        return try await client.send(request).value
      },
      newsItems: { newsFeedUrl in
        let request = Request<NewsItems>(path: "parseNews", query: [("url", newsFeedUrl)])
        return try await client.send(request).value.items
      })
  }
}

extension DateFormatter {
  // 2021-04-25T11:00:00.0000000Z - includes milliseconds
  public static let iso8601TimeZone: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

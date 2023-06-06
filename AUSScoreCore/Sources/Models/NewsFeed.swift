// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - NewsFeed

public struct NewsFeed: Equatable, Identifiable, Codable {
  public let id: Int64
  public let displayName: String
  public let url: String

  public init(id: Int64, displayName: String, url: String) {
    self.id = id
    self.displayName = displayName
    self.url = url
  }
}

extension NewsFeed {
  public static func mock(
    id: Int64,
    displayName: String = "Featured",
    url: String = "https://www.atlanticuniversitysport.com/landing/headlines-featured?feed=rss_2.0")
    -> Self
  {
    .init(id: id, displayName: displayName, url: url)
  }
}

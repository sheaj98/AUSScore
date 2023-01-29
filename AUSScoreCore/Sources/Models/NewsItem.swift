// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - NewsItems

public struct NewsItems: Codable {
  public let items: [NewsItem]

  public init(items: [NewsItem]) {
    self.items = items
  }
}

// MARK: - NewsItem

public struct NewsItem: Equatable, Identifiable, Codable {
  // MARK: Lifecycle

  public init(title: String, link: URL, content: String, imageUrl: URL?, date: Date) {
    self.title = title
    self.link = link
    self.content = content
    self.imageUrl = imageUrl
    self.date = date
  }

  // MARK: Public

  public let title: String
  public let link: URL
  public let content: String
  public let imageUrl: URL?
  public let date: Date

  public var id: String {
    title
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case title
    case link
    case content
    case imageUrl
    case date = "isoDate"
  }
}

extension NewsItem {
  public static func mock(
    title: String,
    link: URL = URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/releases/20221213i6o7s1")!,
    content: String = "Five AUS players named as U SPORTS announces roster for 2023 FISU Winter World University Games.",
    imageUrl: URL =
      URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/photos/WHCK_FISU_1040x680-1040x_mp.jpg")!,
    date: Date = .now)
    -> Self
  {
    .init(title: title, link: link, content: content, imageUrl: imageUrl, date: date)
  }
}

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

  public init(id: String, title: String, link: URL, content: String, imageUrl: URL?, date: Date) {
    self.id = id
    self.title = title
    self.link = link
    self.content = content
    self.imageUrl = imageUrl
    self.date = date
  }

  // MARK: Public
  public let id: String
  public let title: String
  public let link: URL
  public let content: String
  public let imageUrl: URL?
  public let date: Date

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case link
    case content
    case imageUrl
    case date = "isoDate"
  }
}

public extension NewsItem {
  static func mock(
    id: String = "testId",
    title: String = "This is a test title",
    link: URL = URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/releases/20221213i6o7s1")!,
    content: String = "Five AUS players named as U SPORTS announces roster for 2023 FISU Winter World University Games.",
    imageUrl: URL =
      URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/photos/WHCK_FISU_1040x680-1040x_mp.jpg")!,
    date: Date = .now)
    -> Self
  {
    .init(id: id, title: title, link: link, content: content, imageUrl: imageUrl, date: date)
  }
  
  static let placeholderItems = [NewsItem.mock(id: "1"), NewsItem.mock(id: "2"), NewsItem.mock(id: "3"), NewsItem.mock(id: "4"), NewsItem.mock(id: "5"), NewsItem.mock(id: "6"), NewsItem.mock(id: "7"), NewsItem.mock(id: "8"), NewsItem.mock(id: "9"), NewsItem.mock(id: "10")]
}

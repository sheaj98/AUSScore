// Copyright © 2022 Solbits Software Inc. All rights reserved.

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
  public var id: String {
    title
  }

  public let title: String
  public let link: URL
  public let content: String
  public let imageUrl: URL?
  public let date: Date

  enum CodingKeys: String, CodingKey {
    case title
    case link
    case content
    case imageUrl
    case date = "isoDate"
  }

  public init(title: String, link: URL, content: String, imageUrl: URL?, date: Date) {
    self.title = title
    self.link = link
    self.content = content
    self.imageUrl = imageUrl
    self.date = date
  }
}

extension NewsItem {
  public static var mock = Self(
    title: "Twenty two players. One goal.",
    link: URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/releases/20221213i6o7s1")!,
    content: "Five AUS players named as U SPORTS announces roster for 2023 FISU Winter World University Games.",
    imageUrl: URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/photos/WHCK_FISU_1040x680-1040x_mp.jpg")!,
    date: .now)
}

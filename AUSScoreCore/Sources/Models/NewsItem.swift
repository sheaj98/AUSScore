// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Foundation

// MARK: - NewsItem

public struct NewsItem: Equatable, Identifiable {
  public var id: String {
    return title
  }
  public let title: String
  public let link: URL
  public let description: String
  public let imageUrl: URL
  public let date: Date

  public init(title: String, link: URL, description: String, imageUrl: URL, date: Date) {
    self.title = title
    self.link = link
    self.description = description
    self.imageUrl = imageUrl
    self.date = date
  }
}

extension NewsItem {
  public static var mock = Self(
    title: "Twenty two players. One goal.",
    link: URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/releases/20221213i6o7s1")!,
    description: "Five AUS players named as U SPORTS announces roster for 2023 FISU Winter World University Games.",
    imageUrl: URL(string: "http://www.atlanticuniversitysport.com/sports/wice/2022-23/photos/WHCK_FISU_1040x680-1040x_mp.jpg")!,
    date: .now)
}

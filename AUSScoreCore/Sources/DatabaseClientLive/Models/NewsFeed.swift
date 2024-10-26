//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-04-01.
//

import GRDB
import Models

extension NewsFeed: FetchableRecord, PersistableRecord {}

extension NewsFeed {
  public static var databaseTableName: String {
    "newsfeed"
  }
  static let newsFeedCategories = hasMany(NewsFeedCategory.self)

  static let newsItems = hasMany(NewsItem.self, through: newsFeedCategories, using: NewsFeedCategory.newsItem)
  
  var newsItems: QueryInterfaceRequest<NewsItem> {
    request(for: NewsFeed.newsItems)
  }
}

//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-08-21.
//

import GRDB
import Models

extension NewsItem: FetchableRecord, PersistableRecord { }

extension NewsItem {
  public static var databaseTableName: String {
    "news_item"
  }
  static let newsFeedCategories = hasMany(NewsFeedCategory.self)
  static let newsFeeds = hasMany(NewsFeed.self, through: newsFeedCategories, using: NewsFeedCategory.newsFeed)
  
  var newsFeeds: QueryInterfaceRequest<NewsFeed> {
    request(for: NewsItem.newsFeeds)
  }
}

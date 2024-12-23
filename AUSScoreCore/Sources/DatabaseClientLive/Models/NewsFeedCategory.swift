//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-08-27.
//

import GRDB
import Models

extension NewsFeedCategory: FetchableRecord, PersistableRecord {}

extension NewsFeedCategory {
  public static var databaseTableName: String {
    "newsfeed_category"
  }
  static let newsFeed = belongsTo(NewsFeed.self)
  static let newsItem = belongsTo(NewsItem.self)
}

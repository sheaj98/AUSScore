//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2022-12-19.
//

import Foundation

// MARK: - NewsItem

public struct NewsFeed: Equatable, Identifiable, Codable {
  
  public let id: String
  public let displayName: String
  public let url: String

  public init(id: String, displayName: String, url: String) {
    self.id = id
    self.displayName = displayName
    self.url = url
  }
}

extension NewsFeed {
  
  public static func mock(id: String, displayName: String = "Featured", url: String = "https://www.atlanticuniversitysport.com/landing/headlines-featured?feed=rss_2.0") -> Self {
    return .init(id: id, displayName: displayName, url: url)
  }
}


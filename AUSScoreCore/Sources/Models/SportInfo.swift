//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-04-01.
//

import Foundation

// MARK: - Sport

public struct SportInfo: Identifiable, Codable, Equatable {
  public let id: Int64
  public let name: String
  public let gender: Gender
  public let icon: String?
  public let newsFeed: NewsFeed
  public let winValue: Int

  public init(id: Int64, name: String, gender: Gender, icon: String?, newsFeed: NewsFeed, winValue: Int = 2) {
    self.id = id
    self.name = name
    self.gender = gender
    self.icon = icon
    self.newsFeed = newsFeed
    self.winValue = winValue
  }
}

extension SportInfo {
  public static func mock() -> Self {
    .init(id: 1, name: "Men's Basketball", gender: .male, icon: "basketball", newsFeed: .mock(id: 1))
  }
}

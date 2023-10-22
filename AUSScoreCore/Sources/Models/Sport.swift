// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - Sport

public struct Sport: Identifiable, Codable, Equatable {
  public let id: Int64
  public let name: String
  public let gender: Gender
  public let icon: String?
  public let newsfeedID: Int
  public let winValue: Int

  public init(id: Int64, name: String, gender: Gender, icon: String?, newsfeedID: Int, winValue: Int = 2) {
    self.id = id
    self.name = name
    self.gender = gender
    self.icon = icon
    self.newsfeedID = newsfeedID
    self.winValue = winValue
  }
}

// MARK: - Gender

public enum Gender: String, Codable {
  case male = "MALE"
  case female = "FEMALE"
}

extension Sport {
  public static func mock() -> Self {
    .init(id: 1, name: "Men's Basketball", gender: .male, icon: "basketball", newsfeedID: 1)
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - School

public struct School: Equatable, Identifiable, Codable {
  public let id: Int64
  public let name: String
  public let location: String
  public let logo: URL?
  public let displayName: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case location
    case logo
    case displayName = "display_name"
  }

  public init(id: Int64, name: String, location: String, logo: URL?, displayName: String) {
    self.id = id
    self.name = name
    self.location = location
    self.logo = logo
    self.displayName = displayName
  }
}

extension School {
  public static func stfxMock() -> Self {
    .init(
      id: 1,
      name: "St. Francis Xavier",
      location: "Antigonish, NS",
      logo: URL(
        string: "https://res.cloudinary.com/dwxvmohwq/image/upload/v1673652450/aus/stfx.png")!,
      displayName: "StFX"
    )
  }

  public static func unbMock() -> Self {
    .init(
      id: 2,
      name: "University of New Brunswick",
      location: "Fredericton, NB",
      logo: URL(
        string: "https://res.cloudinary.com/dwxvmohwq/image/upload/v1673652450/aus/unb.png")!,
      displayName: "UNB")
  }
}

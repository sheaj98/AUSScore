// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - School

public struct School: Equatable, Identifiable, Codable {
  public let id: Int64
  public let name: String
  public let location: String
  public let logo: URL?
  public let displayName: String
  public let isConference: Bool

  public init(id: Int64, name: String, location: String, logo: URL?, displayName: String, isConference: Bool) {
    self.id = id
    self.name = name
    self.location = location
    self.logo = logo
    self.displayName = displayName
    self.isConference = isConference
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
      displayName: "StFX",
    isConference: true)
  }

  public static func unbMock() -> Self {
    .init(
      id: 2,
      name: "University of New Brunswick",
      location: "Fredericton, NB",
      logo: URL(
        string: "https://res.cloudinary.com/dwxvmohwq/image/upload/v1673652450/aus/unb.png")!,
      displayName: "UNB",
    isConference: true)
  }
}

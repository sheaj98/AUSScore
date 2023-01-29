// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Foundation

// MARK: - School

public struct School: Equatable, Identifiable, Codable {
  public var id: Int64
  public var name: String
  public var location: String
  public var logo: URL?
  public var displayName: String

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
      displayName: "StFX")
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

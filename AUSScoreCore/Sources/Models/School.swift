//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-11.
//

import Foundation

public struct School: Equatable, Identifiable, Codable {
  public let id: UUID
  public let name: String
  public let location: String
  public let logoUrl: URL?
  public let alias: [String]
  public let displayName: String

  public init(id: UUID, name: String, location: String, logoUrl: URL?, alias: [String], displayName: String) {
    self.id = id
    self.name = name
    self.location = location
    self.logoUrl = logoUrl
    self.alias = alias
    self.displayName = displayName
  }
}

public extension School {
  static func mock() -> Self {
    return .init(id: UUID(), name: "St. Francis Xavier", location: "Antigonish, NS", logoUrl: URL(string: "https://github.com/corysullivan/AUSAPI/blob/master/Sources/Assets.xcassets/stfx.imageset/StFX~universal%401x.png")!, alias: ["StFX", "STFX"], displayName: "StFX")
  }
}

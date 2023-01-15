//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-11.
//

import Foundation

public struct School: Equatable, Identifiable, Codable {
  public var id: Int64
  public var name: String
  public var location: String
  public var logoUrl: URL?
  public var alias: [String]
  public var displayName: String

  public init(id: Int64, name: String, location: String, logoUrl: URL?, alias: [String], displayName: String) {
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
    return .init(id: 1, name: "St. Francis Xavier", location: "Antigonish, NS", logoUrl: URL(string: "https://github.com/corysullivan/AUSAPI/blob/master/Sources/Assets.xcassets/stfx.imageset/StFX~universal%401x.png")!, alias: ["StFX", "STFX"], displayName: "StFX")
  }
}

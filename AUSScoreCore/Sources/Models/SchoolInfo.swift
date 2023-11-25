//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-11-21.
//

import Foundation

public struct SchoolInfo: Equatable, Identifiable, Codable {
  public let id: Int64
  public let name: String
  public let location: String
  public let logo: URL?
  public let displayName: String
  public let teams: [TeamInfo]

  public init(id: Int64, name: String, location: String, logo: URL?, displayName: String, teams: [TeamInfo] = []) {
    self.id = id
    self.name = name
    self.location = location
    self.logo = logo
    self.displayName = displayName
    self.teams = teams
  }
}

extension SchoolInfo {
  public static func stfxMock() -> Self {
    .init(
      id: 1,
      name: "St. Francis Xavier",
      location: "Antigonish, NS",
      logo: URL(
        string: "https://res.cloudinary.com/dwxvmohwq/image/upload/v1673652450/aus/stfx.png")!,
      displayName: "StFX",
      teams: [.mock(id: 1, school: .stfxMock(), sport: .mock())]
    )
  }

  public static func unbMock() -> Self {
    .init(
      id: 2,
      name: "University of New Brunswick",
      location: "Fredericton, NB",
      logo: URL(
        string: "https://res.cloudinary.com/dwxvmohwq/image/upload/v1673652450/aus/unb.png")!,
      displayName: "UNB",
      teams: [.mock(id: 2, school: .unbMock(), sport: .mock())]
    )
  }
}

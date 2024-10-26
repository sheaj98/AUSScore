//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-11-02.
//

public struct UserInfo: Codable, Equatable {
  public let id: String
  public let favoriteTeams: [TeamInfo]
  public let favoriteSports: [SportInfo]
  
  public init(id: String, favoriteTeams: [TeamInfo] = [], favoriteSports: [SportInfo] = []) {
    self.id = id
    self.favoriteTeams = favoriteTeams
    self.favoriteSports = favoriteSports
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case favoriteTeams = "favorite_teams"
    case favoriteSports = "favorite_sports"
  }
}

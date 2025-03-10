//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-11-05.
//

public struct AddFavoriteSportRequest: Codable {
  public let sportId: Int64
  
  public init(sportId: Int64) {
    self.sportId = sportId
  }
  
  enum CodingKeys: String, CodingKey {
    case sportId = "sport_id"
  }
}

public struct AddFavoriteTeamRequest: Codable {
  public let teamId: Int64
  
  public init(teamId: Int64) {
    self.teamId = teamId
  }
  
  enum CodingKeys: String, CodingKey {
    case teamId = "team_id"
  }
}

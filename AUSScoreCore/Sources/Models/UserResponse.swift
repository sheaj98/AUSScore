//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-02-20.
//

public struct UserResponse: Codable, Identifiable {
  public let id: String
  public let deviceIds: [String]
  public let favoriteSports: [Int]
  public let favoriteTeams: [Int]
  
  enum CodingKeys: String, CodingKey {
    case id
    case deviceIds = "device_ids"
    case favoriteSports = "favorite_sport_ids"
    case favoriteTeams = "favorite_team_ids"
  }
  
  public init(id: String, deviceIds: [String] = [], favoriteSports: [Int] = [], favoriteTeams: [Int] = []) {
    self.id = id
    self.deviceIds = deviceIds
    self.favoriteSports = favoriteSports
    self.favoriteTeams = favoriteTeams
  }
}

extension UserResponse {
  public static func mock() -> Self {
    return .init(id: "testUserId", deviceIds: ["testDevice1", "testDevice2"])
  }
  
}

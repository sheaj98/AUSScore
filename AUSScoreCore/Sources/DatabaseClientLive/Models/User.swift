//
//  File.swift
//  
//

import Models
import GRDB

extension User: FetchableRecord, PersistableRecord { }
extension UserInfo: FetchableRecord { }

extension User {
  static let favSportPivot = hasMany(FavoriteSport.self)
  static let favoriteSports = hasMany(Sport.self, through: favSportPivot, using: FavoriteSport.sport)
  
  static let favTeamPivot = hasMany(FavoriteTeam.self)
  static let favoriteTeams = hasMany(Team.self, through: favTeamPivot, using: FavoriteTeam.team)
  
  var favoriteTeams: QueryInterfaceRequest<Team> {
    request(for: User.favoriteTeams)
  }
  var favoriteSports: QueryInterfaceRequest<Sport> {
    request(for: User.favoriteSports)
  }
}

public struct FavoriteSport: Codable, FetchableRecord, PersistableRecord {
  public let userId: String
  public let sportId: Int64
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case sportId = "sport_id"
  }
  
  public static var databaseTableName: String {
    "favorite_sport"
  }
  
  public init(userId: String, sportId: Int64) {
    self.userId = userId
    self.sportId = sportId
  }
  
  static let sport = belongsTo(Sport.self)
  static let user = belongsTo(User.self)
  
  var sport: QueryInterfaceRequest<Sport> {
    request(for: FavoriteSport.sport)
  }
  
  var user: QueryInterfaceRequest<User> {
    request(for: FavoriteSport.user)
  }
}

public struct FavoriteTeam: Codable, FetchableRecord, PersistableRecord {
  public let userId: String
  public let teamId: Int64
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case teamId = "team_id"
  }
  
  public init(userId: String, teamId: Int64) {
    self.userId = userId
    self.teamId = teamId
  }
  
  public static var databaseTableName: String {
    "favorite_team"
  }
  
  static let user = belongsTo(User.self)
  static let team = belongsTo(Team.self)
  
  var team: QueryInterfaceRequest<Team> {
    request(for: FavoriteTeam.team)
  }
  
  var user: QueryInterfaceRequest<User> {
    request(for: FavoriteTeam.user)
  }
}

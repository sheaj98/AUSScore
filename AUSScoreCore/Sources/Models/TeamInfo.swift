// Copyright © 2023 Shea Sullivan. All rights reserved.

// MARK: - TeamInfo

public struct TeamInfo: Decodable, Equatable {
  public let id: Int64
  public let sport: Sport
  public let school: School
  public var record: GameRecord?
  
  public struct GameRecord: Decodable, Equatable, CustomStringConvertible {
    public var wins: Int
    public var losses: Int
    public var draws: Int
    public init(wins: Int, losses: Int, draws: Int) {
      self.wins = wins
      self.losses = losses
      self.draws = draws
    }
    public var description: String {
      "\(wins)-\(losses)-\(draws)"
    }
  }

  public init(id: Int64, school: School, sport: Sport, record: GameRecord?) {
    self.id = id
    self.school = school
    self.sport = sport
    self.record = record
  }
}

extension TeamInfo {
  public static func mock(id: Int64, school: School, sport: Sport, wins: Int = 0, losses: Int = 0, draws: Int = 0) -> Self {
    .init(id: id, school: school, sport: sport, record: nil)
  }
}

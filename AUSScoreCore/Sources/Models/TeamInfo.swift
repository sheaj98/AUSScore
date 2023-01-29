// Copyright © 2023 Shea Sullivan. All rights reserved.

// MARK: - TeamInfo

public struct TeamInfo: Decodable, Equatable {
  public let id: Int64
  public let sport: Sport
  public let school: School

  public init(id: Int64, school: School, sport: Sport) {
    self.id = id
    self.school = school
    self.sport = sport
  }
}

extension TeamInfo {
  public static func mock(id: Int64, school: School, sport: Sport) -> Self {
    .init(id: id, school: school, sport: sport)
  }
}

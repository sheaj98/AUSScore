// Copyright © 2023 Solbits Software Inc. All rights reserved.

public struct TeamInfo: Decodable {
  public let id: Int64
  public let sport: Sport
  public let school: School

  public init(id: Int64, school: School, sport: Sport) {
    self.id = id
    self.school = school
    self.sport = sport
  }
}

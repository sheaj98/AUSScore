// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

// MARK: - Team

public struct Team: Identifiable, Codable, Equatable {
  public let id: Int64
  public let sportId: Int64
  public let schoolId: Int64
  public let isConference: Bool

  public init(id: Int64, sportId: Int64, schoolId: Int64, isConference: Bool = false) {
    self.id = id
    self.sportId = sportId
    self.schoolId = schoolId
    self.isConference = isConference
  }
}

extension Team {
  public static func mock() -> Self {
    .init(id: 1, sportId: 1, schoolId: 1)
  }
}

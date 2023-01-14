//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-12.
//

import Foundation

public struct Team: Identifiable, Codable, Equatable {
  public let id: UUID
  public let sportId: UUID
  public let schoolId: UUID

  public init(id: UUID, sportId: UUID, schoolId: UUID) {
    self.id = id
    self.sportId = sportId
    self.schoolId = schoolId
  }
}

public extension Team {
  static func mock() -> Self {
    return .init(id: UUID(), sportId: UUID(), schoolId: UUID())
  }
}

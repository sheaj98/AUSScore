//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-12.
//

import Foundation

public struct Sport: Identifiable, Codable, Equatable {
  public let id: UUID
  public let name: String
  public let gender: Gender

  public init(id: UUID, name: String, gender: Gender) {
    self.id = id
    self.name = name
    self.gender = gender
  }
}

public enum Gender: String, Codable {
  case male = "MALE"
  case female = "FEMALE"
}

public extension Sport {
  static func mock() -> Self {
    return .init(id: UUID(), name: "Men's Basketball", gender: .male)
  }
}

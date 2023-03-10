//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-02-20.
//

public struct User: Codable, Identifiable {
  public let id: String
  public let deviceIds: [String]
}

extension User {
  public static func mock() -> Self {
    return .init(id: "testUserId", deviceIds: ["testDevice1", "testDevice2"])
  }
  
}

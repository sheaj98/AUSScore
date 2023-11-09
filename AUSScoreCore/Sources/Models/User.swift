//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-11-02.
//

public struct User: Codable {
  public let id: String
  
  public init(id: String) {
    self.id = id
  }
}

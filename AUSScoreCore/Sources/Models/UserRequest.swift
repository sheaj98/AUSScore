//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-02-20.
//

import Foundation

public struct UserRequest: Codable {
  public let id: String
  public let deviceId: String
  
  public init(id: String, deviceId: String) {
    self.id = id
    self.deviceId = deviceId
  }
}

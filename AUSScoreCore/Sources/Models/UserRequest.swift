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
  
  enum CodingKeys: String, CodingKey {
    case id = "user_id"
    case deviceId = "device_id"
  }
  
  public init(id: String, deviceId: String) {
    self.id = id
    self.deviceId = deviceId
  }
}

//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2023-01-23.
//

import Foundation

public struct GameInfo: Decodable {
  public let id: String
  public let startTime: Date
  public let status: GameStatus
  public let currentTime: String?
  public let sport: Sport
  public let gameResults: [GameResultInfo]

  public init(id: String, startTime: Date, status: GameStatus, currentTime: String?, sport: Sport, gameResults: [GameResultInfo]) {
    self.id = id
    self.startTime = startTime
    self.status = status
    self.currentTime = currentTime
    self.sport = sport
    self.gameResults = gameResults
  }
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import AUSClient
import ComposableArchitecture
import DatabaseClient
import DatabaseClientLive
import Foundation
import ScoresFeature
import Models
import UserIdentifier
import UIKit

// MARK: - SyncLogic

public struct SyncLogic: Reducer {
  // MARK: Public

  public var body: some Reducer<AppReducer.State, AppReducer.Action> {
    Reduce { _, action in
      switch action {
      case .appDelegate(.didFinishLaunching):
        return syncAll()
      case .appDelegate(.appDidBecomeActive):
        return syncGames(completionHandler: nil)
      case .appDelegate(.didRegisterForRemoteNotifications(.success(let tokenData))):
        return .run { _ in
          let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
          do {
            let userId = try await userIdentifier.id()
            let _ = try await ausClient.upsertUser(UserRequest(id: userId, deviceId: token))
          } catch {
            print("Failed to update user or device \(error)")
          }
        }
      case .appDelegate(.didRecieveRemoteNotification(let completionHandler)):
        //TODO: Move to proper handler
        return syncGames(completionHandler: completionHandler)
      case .scores(.scoresLists(.element(_, action: .refreshGames))):
        return syncGames(completionHandler: nil)
      case .favorites(.resetDb):
        return .concatenate([.run { _ in
          do {
            try await databaseClient.resetLocalDB()
          } catch {
            print("Failed to reset local db \(error)")
          }
        }, syncAll()])
      default:
        return .none
      }
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var ausClient
  @Dependency(\.databaseClient) var databaseClient
  @Dependency(\.userIdentifier) var userIdentifier
  // MARK: Private

  private func syncGames(completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Effect<Action> {
    return .run { _ in
      do {
        let remoteGames = try await ausClient.allGames()
        try await databaseClient.syncGames(remoteGames)

        let remoteGameResults = try await ausClient.gameResults()
        try await databaseClient.syncGameResults(remoteGameResults)
        
        if let cb = completionHandler {
          cb(.newData)
        }
      } catch {
        if let cb = completionHandler {
          cb(.failed)
        }
        print("Syncing games failed")
      }
    }
  }

  private func syncAll() -> Effect<Action> {
    .run { _ in
      do {
        try await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            let remoteSchools = try await ausClient.schools()
            try await databaseClient.syncSchools(remoteSchools)
          }

          group.addTask {
            let remoteNewsFeeds = try await ausClient.newsFeeds()
            try await databaseClient.syncNewsFeeds(remoteNewsFeeds)
          }
          try await group.waitForAll()
        }
        
        let remoteSports = try await ausClient.sports()
        try await databaseClient.syncSports(remoteSports)

        try await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            let remoteTeams = try await ausClient.teams()
            try await databaseClient.syncTeams(remoteTeams)
          }

          group.addTask {
            let remoteGames = try await ausClient.allGames()
            try await databaseClient.syncGames(remoteGames)
          }
          try await group.waitForAll()
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            let remoteGameResults = try await ausClient.gameResults()
            try await databaseClient.syncGameResults(remoteGameResults)
          }
          
          group.addTask {
            let userId = try await userIdentifier.id()
            let user = try await ausClient.getUser(userId)
            try await databaseClient.syncUser(user)
          }
          
          try await group.waitForAll()
        }
        
       
      } catch {
        print("Syncing failed \(error)")
      }
    }
  }
}

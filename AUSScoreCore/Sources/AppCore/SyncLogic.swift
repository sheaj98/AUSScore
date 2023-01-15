// Copyright © 2023 Solbits Software Inc. All rights reserved.

import AUSClient
import ComposableArchitecture
import DatabaseClient
import DatabaseClientLive
import Foundation

// MARK: - SyncLogic

public struct SyncLogic: ReducerProtocol {
  // MARK: Public

  public var body: some ReducerProtocol<AppReducer.State, AppReducer.Action> {
    Reduce { _, action in
      switch action {
      case .appDelegate(.didFinishLaunching):
        return syncAll()
      default:
        return .none
      }
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var ausClient
  @Dependency(\.databaseClient) var databaseClient

  // MARK: Private

  private func syncAll() -> EffectTask<Action> {
    .fireAndForget {
      do {
        try await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            let remoteSchools = try await ausClient.schools()
            try await databaseClient.syncSchools(remoteSchools)
          }

          group.addTask {
            let remoteSports = try await ausClient.sports()
            try await databaseClient.syncSports(remoteSports)
          }
          for try await _ in group { }
        }

        let remoteTeams = try await ausClient.teams()
        try await databaseClient.syncTeams(remoteTeams)
      } catch {
        print("Syncing failed \(error)")
      }
    }
  }
}

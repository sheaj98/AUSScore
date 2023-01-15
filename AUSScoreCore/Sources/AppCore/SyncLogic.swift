// Copyright © 2023 Solbits Software Inc. All rights reserved.

import AUSClient
import ComposableArchitecture
import DatabaseClient
import Foundation

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
        let remoteSchools = try await ausClient.schools()
        try await databaseClient.syncSchools(remoteSchools)
      } catch {
        print("Syncing failed \(error)")
      }
    }
  }
}

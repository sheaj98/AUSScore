// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import Foundation
import RemoteNotificationsClient
import UserNotificationsClient
import UIKit

public struct AppDelegateReducer: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  public struct State: Equatable {
    public init() {}
  }
  public enum Action {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case didRecieveRemoteNotification(((UIBackgroundFetchResult) -> Void)?)
    case userNotifications(UserNotificationClient.DelegateEvent)
  }

  public func reduce(into _: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .didFinishLaunching:
      let notificationEvents = userNotifications.delegate()
      return .run { send in
        await withThrowingTaskGroup(of: Void.self) { group in
                  group.addTask {
                    for await event in notificationEvents {
                      await send(.userNotifications(event))
                    }
                  }
                  group.addTask {
//                    let settings = await self.userNotifications.getNotificationSettings()
//                    switch settings.authorizationStatus {
//                    case .authorized:
//                      guard
//                        try await self.userNotifications.requestAuthorization([.alert, .sound, .badge]) else { return }
//                    case .notDetermined, .provisional:
//                      guard try await self.userNotifications.requestAuthorization(.provisional) else { return }
//                    default:
//                      return
//                    }
                    await self.remoteNotifications.register()
                  }
                }
      }
      
    case .didRegisterForRemoteNotifications(.failure):
      return .none
      
    default:
      return .none
    }
  }

  @Dependency(\.remoteNotifications) var remoteNotifications
  @Dependency(\.userNotifications) var userNotifications
}

// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import Foundation
import RemoteNotificationsClient
import UIKit
import UserNotificationsClient

public struct AppDelegateReducer: Reducer {
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
    case appDidBecomeActive
  }

  public func reduce(into _: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      let notificationEvents = userNotifications.delegate()
      return .merge(
        .publisher { NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
          .map { _ in .appDidBecomeActive }}
          ,

        .run { send in
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
      )

    case .didRegisterForRemoteNotifications(.failure):
      return .none

    default:
      return .none
    }
  }

  @Dependency(\.remoteNotifications) var remoteNotifications
  @Dependency(\.userNotifications) var userNotifications
}

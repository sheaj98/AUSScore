// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Combine
import Dependencies
import UserNotifications

// MARK: - UserNotificationClient + DependencyKey

extension UserNotificationClient: DependencyKey {
  public static let liveValue = Self(
    add: { try await UNUserNotificationCenter.current().add($0) },
    delegate: {
      AsyncStream { continuation in
        let delegate = Delegate(continuation: continuation)
        UNUserNotificationCenter.current().delegate = delegate
        continuation.onTermination = { [delegate] _ in
          // We need to reference the delegate inside the closure otherwise the delegate is released.
          // This seems to be the only way to create a strong reference to the delegate.
          _ = delegate
        }
      }
    },
    getNotificationSettings: {
      await Notification.Settings(
        rawValue: UNUserNotificationCenter.current().notificationSettings())
    },
    removeDeliveredNotificationsWithIdentifiers: {
      UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
    },
    removePendingNotificationRequestsWithIdentifiers: {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: $0)
    },
    removeAll: {
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    },
    requestAuthorization: {
      try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
    })
}

extension UserNotificationClient.Notification {
  public init(rawValue: UNNotification) {
    date = rawValue.date
    request = rawValue.request
  }
}

extension UserNotificationClient.Notification.Response {
  public init(rawValue: UNNotificationResponse) {
    notification = .init(rawValue: rawValue.notification)
  }
}

extension UserNotificationClient.Notification.Settings {
  public init(rawValue: UNNotificationSettings) {
    authorizationStatus = rawValue.authorizationStatus
  }
}

// MARK: - UserNotificationClient.Delegate

extension UserNotificationClient {
  fileprivate class Delegate: NSObject, UNUserNotificationCenterDelegate {
    // MARK: Lifecycle

    init(continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation) {
      self.continuation = continuation
    }

    // MARK: Internal

    let continuation: AsyncStream<UserNotificationClient.DelegateEvent>.Continuation

    func userNotificationCenter(
      _: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void)
    {
      continuation.yield(
        .didReceiveResponse(.init(rawValue: response)) { completionHandler() })
    }

    func userNotificationCenter(
      _: UNUserNotificationCenter,
      openSettingsFor notification: UNNotification?)
    {
      continuation.yield(
        .openSettingsForNotification(notification.map(Notification.init(rawValue:))))
    }

    func userNotificationCenter(
      _: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void)
    {
      continuation.yield(
        .willPresentNotification(.init(rawValue: notification)) { completionHandler($0) })
    }
  }
}

// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Combine
import Dependencies
import UserNotifications

// MARK: - UserNotificationClient

public struct UserNotificationClient {
  public enum DelegateEvent: Equatable {
    case didReceiveResponse(Notification.Response, completionHandler: @Sendable () -> Void)
    case openSettingsForNotification(Notification?)
    case willPresentNotification(
      Notification, completionHandler: @Sendable (UNNotificationPresentationOptions) -> Void)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.didReceiveResponse(let lhs, _), .didReceiveResponse(let rhs, _)):
        return lhs == rhs
      case (.openSettingsForNotification(let lhs), .openSettingsForNotification(let rhs)):
        return lhs == rhs
      case (.willPresentNotification(let lhs, _), .willPresentNotification(let rhs, _)):
        return lhs == rhs
      default:
        return false
      }
    }
  }

  public struct Notification: Equatable {
    // MARK: Lifecycle

    public init(
      date: Date,
      request: UNNotificationRequest)
    {
      self.date = date
      self.request = request
    }

    // MARK: Public

    public struct Response: Equatable {
      public var notification: Notification

      public init(notification: Notification) {
        self.notification = notification
      }
    }

    // TODO: should this be nested in UserNotificationClient instead of Notification?
    public struct Settings: Equatable {
      public var authorizationStatus: UNAuthorizationStatus

      public init(authorizationStatus: UNAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
      }
    }

    public var date: Date
    public var request: UNNotificationRequest
  }

  public var add: @Sendable (UNNotificationRequest) async throws -> Void
  public var delegate: @Sendable () -> AsyncStream<DelegateEvent>
  public var getNotificationSettings: @Sendable () async -> Notification.Settings
  public var removeDeliveredNotificationsWithIdentifiers: @Sendable ([String]) async -> Void
  public var removePendingNotificationRequestsWithIdentifiers: @Sendable ([String]) async -> Void
  public var removeAll: @Sendable () async -> Void
  public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
}

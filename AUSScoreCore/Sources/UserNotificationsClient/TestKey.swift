// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  public var userNotifications: UserNotificationClient {
    get { self[UserNotificationClient.self] }
    set { self[UserNotificationClient.self] = newValue }
  }
}

// MARK: - UserNotificationClient + TestDependencyKey

extension UserNotificationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue: UserNotificationClient = Self(
    add: unimplemented("\(Self.self).add"),
    delegate: unimplemented("\(Self.self).delegate", placeholder: .finished),
    getNotificationSettings: unimplemented(
      "\(Self.self).getNotificationSettings",
      placeholder: Notification.Settings(authorizationStatus: .notDetermined)),
    removeDeliveredNotificationsWithIdentifiers: unimplemented(
      "\(Self.self).removeDeliveredNotificationsWithIdentifiers"),
    removePendingNotificationRequestsWithIdentifiers: unimplemented(
      "\(Self.self).removePendingNotificationRequestsWithIdentifiers"),
    removeAll: unimplemented("\(Self.self).removeAll"),
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization"))
}

extension UserNotificationClient {
  public static let noop = Self(
    add: { _ in },
    delegate: { AsyncStream { _ in } },
    getNotificationSettings: { Notification.Settings(authorizationStatus: .notDetermined) },
    removeDeliveredNotificationsWithIdentifiers: { _ in },
    removePendingNotificationRequestsWithIdentifiers: { _ in },
    removeAll: { () in },
    requestAuthorization: { _ in false })
}

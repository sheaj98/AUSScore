// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies

extension DependencyValues {
  // MARK: Public

  public var remoteNotifications: RemoteNotificationsClient {
    get { self[RemoteNotificationsClientKey.self] }
    set { self[RemoteNotificationsClientKey.self] = newValue }
  }

  // MARK: Private

  private enum RemoteNotificationsClientKey: DependencyKey {
    static let liveValue = RemoteNotificationsClient.live
    static let testValue = RemoteNotificationsClient.unimplementedTests
    static let previewValue = RemoteNotificationsClient.noop
  }
}

// MARK: - RemoteNotificationsClient

public struct RemoteNotificationsClient {
  public var isRegistered: @Sendable () async -> Bool
  public var register: @Sendable () async -> Void
  public var unregister: @Sendable () async -> Void
}

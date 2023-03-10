import Combine
import Dependencies
import Foundation

// MARK: - AppNotificationsClient

extension DependencyValues {
  public var appNotificationsClient: AppNotificationsClient {
    get { self[AppNotificationsClient.self] }
    set { self[AppNotificationsClient.self] = newValue }
  }
}

// MARK: - AppNotificationsClient

public struct AppNotificationsClient {
  public var didBecomeActive: () -> AsyncStream<Void>
  public var didEnterBackground: () -> AsyncStream<Void>
  public var didChangeDay: () -> AsyncStream<Void>
  public var didChangeExternalStore: () -> AsyncStream<Notification>
}

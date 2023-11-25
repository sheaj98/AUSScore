#if os(iOS)
import BackgroundTasks
import Dependencies
import Foundation
public struct BackgroundTaskClient {
  public var schedule: @Sendable () async throws -> Void
  public var cancelAll: @Sendable () async throws -> Void
}
#endif

// Not supported on macOS
#if os(macOS)
public struct BackgroundTaskClient { }
#endif

extension DependencyValues {
  // MARK: Public

  public var backgroundTaskClient: BackgroundTaskClient {
    get { self[BackgroundTaskClientKey.self] }
    set { self[BackgroundTaskClientKey.self] = newValue }
  }

  // MARK: Private

  private enum BackgroundTaskClientKey: DependencyKey {
    static let liveValue = BackgroundTaskClient.live
    static let testValue = BackgroundTaskClient.unimplemented
  }
}

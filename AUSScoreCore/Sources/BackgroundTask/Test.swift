import Foundation
import XCTestDynamicOverlay

extension BackgroundTaskClient {
  public static let noop = Self(
    schedule: { try await Task.never() },
    cancelAll: { try await Task.never() })

  public static let unimplemented = Self(
    schedule: XCTUnimplemented("\(Self.self).schedule"),
    cancelAll: XCTUnimplemented("\(Self.self).cancelAll"))
}

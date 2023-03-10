import CloudKit
import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
  // MARK: Public
  public var userIdentifier: UserIdentifier {
    get { self[UserIdentifierKey.self] }
    set { self[UserIdentifierKey.self] = newValue }
  }

  // MARK: Private
  private enum UserIdentifierKey: DependencyKey {
    static let liveValue = UserIdentifier.live
    static let testValue = UserIdentifier.unimplemented
  }
}

// MARK: - UserIdentifier
public struct UserIdentifier {
  public var id: () async throws -> String
}

// MARK: - UserIdentifierError
enum UserIdentifierError: Error {
  case noRecordFound
}

// MARK: - Live
extension UserIdentifier {
  public static let live = Self(
    id: { () in
      try await CKContainer.default().userRecordID().recordName
    })
}

// MARK: - Mock
extension UserIdentifier {
  public static let unimplemented = Self(
    id: XCTUnimplemented("\(Self.self).id"))
}

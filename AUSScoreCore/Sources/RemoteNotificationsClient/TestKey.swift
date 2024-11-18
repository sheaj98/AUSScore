// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension RemoteNotificationsClient {
  public static let noop = Self(
    isRegistered: { true },
    register: { },
    unregister: { })
}

extension RemoteNotificationsClient {
  public static let unimplementedTests = Self(
    isRegistered: unimplemented("\(Self.self).isRegistered", placeholder: false),
    register: unimplemented("\(Self.self).register"),
    unregister: unimplemented("\(Self.self).unregister"))
}

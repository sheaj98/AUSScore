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
  public static let unimplemented = Self(
    isRegistered: XCTUnimplemented("\(Self.self).isRegistered", placeholder: false),
    register: XCTUnimplemented("\(Self.self).register"),
    unregister: XCTUnimplemented("\(Self.self).unregister"))
}

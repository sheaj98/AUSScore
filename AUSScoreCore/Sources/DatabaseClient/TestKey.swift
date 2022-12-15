// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DatabaseClient: TestDependencyKey {
  public static let testValue = Self(newsItems: unimplemented("\(Self.self).newsItems"))

  public static let previewValue = Self(newsItems: { () in
    [.mock, .mock]
  })
}

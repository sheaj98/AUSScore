// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension APIClient: TestDependencyKey {
  public static let testValue = Self(topNews: unimplemented("\(Self.self).newsItems"))

  public static let previewValue = Self(topNews: { () in
    [.mock]
  })
}

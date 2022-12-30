// Copyright © 2022 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension AUSClient: TestDependencyKey {
  public static let testValue = Self(newsFeeds: unimplemented("\(Self.self).newsFeeds"), newsItems: unimplemented("\(Self.self).newsItems"))

  public static let previewValue = Self(newsFeeds: { () in
    [.mock(id: "123"), .mock(id: "1234"), .mock(id: "12345")]
  }, newsItems: { _ in
    [.mock(title: "Title1"), .mock(title: "Title2"), .mock(title: "Title3")]
  })
}

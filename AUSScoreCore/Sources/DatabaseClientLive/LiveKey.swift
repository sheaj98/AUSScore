// Copyright © 2022 Solbits Software Inc. All rights reserved.

import DatabaseClient
import Dependencies
import Foundation

extension DatabaseClient: DependencyKey {
  public static let liveValue = Self(newsItems: { () in [] })
}

// Copyright © 2022 Solbits Software Inc. All rights reserved.

import APIClient
import Dependencies
import Foundation
import Models

extension APIClient: DependencyKey {
  public static let liveValue = Self(topNews: { () in [.mock] })
}

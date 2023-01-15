// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DatabaseClient: TestDependencyKey {
  public static let testValue = Self(
    schools: unimplemented("\(Self.self).schools"),
    syncSchools: unimplemented("\(Self.self).syncSchools"),
    sports: unimplemented("\(Self.self).sports"),
    syncSports: unimplemented("\(Self.self).syncSports"))
}

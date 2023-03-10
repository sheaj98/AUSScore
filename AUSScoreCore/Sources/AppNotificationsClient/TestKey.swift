// Copyright © 2023 Solbits Software Inc. All rights reserved.

import Dependencies

extension AppNotificationsClient: TestDependencyKey {
  public static let testValue = AppNotificationsClient(
    didBecomeActive: { .never },
    didEnterBackground: { .never },
    didChangeDay: { .never },
    didChangeExternalStore: { .never })
}

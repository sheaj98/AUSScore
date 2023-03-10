// Copyright © 2023 Solbits Software Inc. All rights reserved.

import UIKit

@available(iOSApplicationExtension, unavailable)
extension RemoteNotificationsClient {
  public static let live = Self(
    isRegistered: { await UIApplication.shared.isRegisteredForRemoteNotifications },
    register: {
      await UIApplication.shared.registerForRemoteNotifications()
    },
    unregister: { await UIApplication.shared.unregisterForRemoteNotifications() })
}

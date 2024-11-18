// Copyright © 2023 Solbits Software Inc. All rights reserved.

import UIKit

@available(iOSApplicationExtension, unavailable)
extension RemoteNotificationsClient {
  public static let live = Self(
    isRegistered: { UIApplication.shared.isRegisteredForRemoteNotifications },
    register: {
      UIApplication.shared.registerForRemoteNotifications()
    },
    unregister: { UIApplication.shared.unregisterForRemoteNotifications() })
}

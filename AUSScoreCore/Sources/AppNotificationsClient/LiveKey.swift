import Dependencies
import Foundation
import UIKit

extension AppNotificationsClient: DependencyKey {
  public static var liveValue = AppNotificationsClient(
    didBecomeActive: {
      NotificationCenter.default
        .notifications(named: UIApplication.didBecomeActiveNotification)
        .map { _ in }
        .eraseToStream()

    },
    didEnterBackground: {
      NotificationCenter.default
        .notifications(named: UIApplication.didEnterBackgroundNotification)
        .map { _ in }
        .eraseToStream()
    },
    didChangeDay: {
      NotificationCenter.default
        .notifications(named: .NSCalendarDayChanged)
        .map { _ in }
        .eraseToStream()
    },
    didChangeExternalStore: {
      NotificationCenter.default
        .notifications(named: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
        .eraseToStream()
    })
}

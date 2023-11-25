import BackgroundTasks
import Foundation

// To test, pause execution on a device and run
// ```
// e -l objc -- (void)[[BGTaskScheduler sharedScheduler]
// _simulateLaunchForTaskWithIdentifier:@"com.solbits.timestack.refreshEvents"]
// ```

extension BackgroundTaskClient {
  public static let refreshIdentifier = "com.sheasullivan.ausscore.refreshGames"

  #if os(macOS)
  public static let live = BackgroundTaskClient()
  #elseif os(iOS)

  public static let live = Self(
    schedule: {
      BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.refreshIdentifier)
      let today = Calendar.current.startOfDay(for: .now)
      let midnight = Calendar.current.date(byAdding: .day, value: 1, to: today)
      let request = BGAppRefreshTaskRequest(identifier: Self.refreshIdentifier)
      request.earliestBeginDate = midnight
      try BGTaskScheduler.shared.submit(request)
    },
    cancelAll: {
      BGTaskScheduler.shared.cancelAllTaskRequests()
    })
  #endif
}

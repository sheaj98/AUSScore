// Copyright © 2023 Solbits Software Inc. All rights reserved.

import AppCore
import ComposableArchitecture
import SwiftUI

// MARK: - AUSScoreApp

@main
struct AUSScoreApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView(store: self.appDelegate.store)
    }
  }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store: StoreOf<AppReducer> = {
    return Store(
      initialState: AppReducer.State(),
      reducer: AppReducer())
  }()

  lazy var viewStore = ViewStore(
    self.store.scope(state: { _ in () }),
    removeDuplicates: ==)

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    viewStore.send(.appDelegate(.didFinishLaunching))
    return true
  }

  // MARK: - UISceneSession Lifecycle

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions)
    -> UISceneConfiguration
  {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {
//    viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
  }

  func application(
    _: UIApplication,
    didReceiveRemoteNotification _: [AnyHashable: Any],
    fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void)
  {
//    viewStore.send(.background(.didReceiveRemoteNotification(userInfo: userInfo, completionHandler: completionHandler)))
  }

  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {
//    viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError))))
  }
}

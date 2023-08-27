// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCore
import ComposableArchitecture
import SwiftUI
import Nuke

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
  let store: StoreOf<AppReducer> = Store(
    initialState: AppReducer.State(),
    reducer: AppReducer())

  lazy var viewStore = ViewStore(
    self.store.scope(state: { _ in () }),
    removeDuplicates: ==)

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    viewStore.send(.appDelegate(.didFinishLaunching))
    ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
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

  func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
    }

    func application(
      _: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
      viewStore.send(.appDelegate(.didRecieveRemoteNotification(completionHandler)))
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError))))
    }
}

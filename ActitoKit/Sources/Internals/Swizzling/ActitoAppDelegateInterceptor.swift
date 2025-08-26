//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

@objc
public protocol ActitoAppDelegateInterceptor {
//    @objc optional func applicationDidBecomeActive(_ application: UIApplication)
//
//    @objc optional func applicationWillResignActive(_ application: UIApplication)

    @MainActor
    @objc optional func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

    @MainActor
    @objc optional func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    @MainActor
    @objc optional func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    @MainActor
    @objc optional func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool

    @MainActor
    @objc optional func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
}

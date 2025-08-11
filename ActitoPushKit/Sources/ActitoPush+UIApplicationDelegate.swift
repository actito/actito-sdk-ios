//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UIKit

extension ActitoPush: ActitoPushUIApplicationDelegate {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        applicationDelegateInterceptor.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        applicationDelegateInterceptor.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        applicationDelegateInterceptor.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        await withCheckedContinuation { continuation in
            applicationDelegateInterceptor.application(application, didReceiveRemoteNotification: userInfo) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

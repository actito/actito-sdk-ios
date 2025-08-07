//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import UIKit

public protocol ActitoPushUIApplicationDelegate {
    /// Called when the app successfully registers with Apple Push Notification Service (APNS).
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - token:  The device token data for remote notifications.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data)

    /// Called when the app fails to register for remote notifications.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - error: An error object describing why registration failed.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    /// Called when a remote notification is received. Used to handle notification content and initiate background processing if necessary.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - userInfo: The payload of the received remote notification.
    ///   - completionHandler: A handler to be called with a `UIBackgroundFetchResult` after processing the notification.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    /// Called when a remote notification is received. Provides async support for handling the notification.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - userInfo: The payload of the received remote notification.
    ///
    /// - Returns: A `UIBackgroundFetchResult` indicating the result of the background fetch operation.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult
}

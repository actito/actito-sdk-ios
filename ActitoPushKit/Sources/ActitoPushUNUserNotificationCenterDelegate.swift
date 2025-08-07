//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation
import UserNotifications

public protocol ActitoPushUNUserNotificationCenterDelegate {
    /// Called when a notification prompts the app to open its settings screen.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification that prompted the settings to be opened, if applicable.
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)

    /// Called when the user interacts with a notification.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - response: The user’s response to the notification.
    ///   - completionHandler: A completion handler to call after processing the response.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)

    /// Called asynchronously when the user interacts with a notification.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - response: The user’s response to the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async

    /// Called when a notification is delivered to the app while it’s in the foreground.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification being presented.
    ///   - completionHandler: A completion handler to call with the desired presentation options.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

    /// Called asynchronously when a notification is delivered to the app while it’s in the foreground.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification being presented.
    ///
    /// - Returns: The desired presentation options for the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
}

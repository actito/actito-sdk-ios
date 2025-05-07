//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation
import UserNotifications

public protocol ActitoPushDelegate: AnyObject {
    /// Called when the app encounters an error during the registration process for remote notifications.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - error: An ``Error`` object describing the reason for the registration failure.
    func actito(_ actitoPush: ActitoPush, didFailToRegisterForRemoteNotificationsWithError error: Error)

    /// Called when the device's push subscription changes.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - subscription: The updated ``ActitoPushSubscription``, or `nil` if the subscription token is unavailable.
    func actito(_ actitoPush: ActitoPush, didChangeSubscription subscription: ActitoPushSubscription?)

    /// Called when the notification settings are changed.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - allowedUI: A Boolean indicating whether the app is permitted to display notifications. `true` if notifications are allowed, `false` if they are restricted by the user.
    func actito(_ actitoPush: ActitoPush, didChangeNotificationSettings allowedUI: Bool)

    /// Called when an unknown type of notification is received.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - userInfo: A dictionary containing the payload data of the unknown notification.
    func actito(_ actitoPush: ActitoPush, didReceiveUnknownNotification userInfo: [AnyHashable: Any])

    /// Called when a push notification is received.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - notification: The received ``ActitoNotification`` object.
    ///   - deliveryMechanism: The ``ActitoNotificationDeliveryMechanism`` used to deliver the notification.
    func actito(_ actitoPush: ActitoPush, didReceiveNotification notification: ActitoNotification, deliveryMechanism: ActitoNotificationDeliveryMechanism)

    /// Called when a custom system notification is received.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - notification: The received ``ActitoSystemNotification``.
    func actito(_ actitoPush: ActitoPush, didReceiveSystemNotification notification: ActitoSystemNotification)

    /// Called when a notification prompts the app to open its settings screen.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - notification: The received ``ActitoSystemNotification``.
    func actito(_ actitoPush: ActitoPush, shouldOpenSettings notification: ActitoNotification?)

    /// Called when a push notification is opened by the user.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - notification: The ``ActitoNotification`` that was opened.
    func actito(_ actitoPush: ActitoPush, didOpenNotification notification: ActitoNotification)

    /// Called when an unknown push notification is opened by the user.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - userInfo: A dictionary containing the payload data of the unknown notification.
    func actito(_ actitoPush: ActitoPush, didOpenUnknownNotification userInfo: [AnyHashable: Any])

    /// Called when a push notification action is opened by the user.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - action: The specific ``ActitoNotification.Action`` opened by the user.
    ///   - notification: The ``ActitoNotification`` containing the action.
    func actito(_ actitoPush: ActitoPush, didOpenAction action: ActitoNotification.Action, for notification: ActitoNotification)

    /// Called when an unknown push notification action is opened by the user.
    ///
    /// - Parameters:
    ///   - actitoPush: The ActitoPush object instance.
    ///   - action: The specific action opened by the user.
    ///   - notification: A dictionary containing the payload data of the unknown notification.
    ///   - responseText: A string representing the action response, if not one of the defaults.
    func actito(_ actitoPush: ActitoPush, didOpenUnknownAction action: String, for notification: [AnyHashable: Any], responseText: String?)
}

extension ActitoPushDelegate {
    public func actito(_: ActitoPush, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    public func actito(_: ActitoPush, didChangeSubscription _: ActitoPushSubscription?) {}

    public func actito(_: ActitoPush, didChangeNotificationSettings _: Bool) {}

    public func actito(_: ActitoPush, didReceiveUnknownNotification _: [AnyHashable: Any]) {}

    public func actito(_: ActitoPush, didReceiveNotification _: ActitoNotification, deliveryMechanism _: ActitoNotificationDeliveryMechanism) {}

    public func actito(_: ActitoPush, didReceiveSystemNotification _: ActitoSystemNotification) {}

    public func actito(_: ActitoPush, shouldOpenSettings _: ActitoNotification?) {}

    public func actito(_: ActitoPush, didOpenNotification _: ActitoNotification) {}

    public func actito(_: ActitoPush, didOpenUnknownNotification _: [AnyHashable: Any]) {}

    public func actito(_: ActitoPush, didOpenAction _: ActitoNotification.Action, for _: ActitoNotification) {}

    public func actito(_: ActitoPush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {}
}

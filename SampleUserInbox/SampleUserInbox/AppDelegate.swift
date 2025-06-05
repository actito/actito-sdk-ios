//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoPushKit
import ActitoPushUIKit
import ActivityKit
import CoreLocation
import Foundation
import OSLog
import StoreKit
import SwiftUI
import UIKit

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal var window: UIWindow?

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if #available(iOS 14.0, *) {
            Actito.shared.push().presentationOptions = [.banner, .badge, .sound]
        } else {
            Actito.shared.push().presentationOptions = [.alert, .badge, .sound]
        }

        Actito.shared.delegate = self
        Actito.shared.push().delegate = self
        Actito.shared.pushUI().delegate = self

        Task {
            do {
                try await Actito.shared.launch()
            } catch {
                Logger.main.error("Failed to launch Actito. \(error)")
            }
        }

        if Actito.shared.canEvaluateDeferredLink {
            Actito.shared.evaluateDeferredLink { result in
                switch result {
                case let .success(evaluated):
                    Logger.main.info("deferred link evaluation = \(evaluated)")
                case let .failure(error):
                    Logger.main.error("Failed to evaluate the deferred link. \(error)")
                }
            }
        }

        return true
    }

    internal func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    internal func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    internal func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}
}

extension AppDelegate: ActitoDelegate {
    internal func actito(_: Actito, onReady _: ActitoApplication) {
        Logger.main.info("Actito finished launching.")

        NotificationCenter.default.post(
            name: .actitoStatus,
            object: nil,
            userInfo: ["ready": true]
        )
    }

    internal func actitoDidUnlaunch(_: Actito) {
        Logger.main.info("Actito finished un-launching.")

        NotificationCenter.default.post(
            name: .actitoStatus,
            object: nil,
            userInfo: ["ready": false]
        )
    }

    internal func actito(_: Actito, didRegisterDevice device: ActitoDevice) {
        Logger.main.info("Actito: device registered: \(String(describing: device))")
    }
}

extension AppDelegate: ActitoPushDelegate {
    internal func actito(_: ActitoPush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.main.error("Actito: failed to register for remote notifications: \(error)")
    }

    internal func actito(_ actitoPush: any ActitoPush, didChangeSubscription subscription: ActitoPushSubscription?) {
        Logger.main.info("Actito: subscription changed: \(String(describing: subscription))")
    }

    internal func actito(_: ActitoPush, didChangeNotificationSettings allowedUI: Bool) {
        Logger.main.info("Actito: notification settings changed: \(allowedUI)")

        NotificationCenter.default.post(
            name: .notificationSettingsChanged,
            object: nil
        )
    }

    internal func actito(_: ActitoPush, didReceiveSystemNotification notification: ActitoSystemNotification) {
        Logger.main.info("Actito: received a system notification: \(String(describing: notification))")
    }

    internal func actito(_: ActitoPush, didReceiveNotification notification: ActitoNotification, deliveryMechanism: ActitoNotificationDeliveryMechanism) {
        Logger.main.info("Actito: received a notification: \(String(describing: notification))")
        Logger.main.info("Actito: received notification delivery mechanism: \(deliveryMechanism.rawValue)")

        NotificationCenter.default.post(
            name: .notifyInboxUpdate,
            object: nil
        )
    }

    internal func actito(_: ActitoPush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        Logger.main.info("Actito: received an unknown notification: \(userInfo)")
    }

    internal func actito(_: ActitoPush, shouldOpenSettings _: ActitoNotification?) {
        Logger.main.info("Actito: should open notification settings")
    }

    internal func actito(_: ActitoPush, didOpenNotification notification: ActitoNotification) {
        UIApplication.shared.present(notification)

        NotificationCenter.default.post(
            name: .notifyInboxUpdate,
            object: nil
        )
    }

    internal func actito(_: ActitoPush, didOpenAction action: ActitoNotification.Action, for notification: ActitoNotification) {
        guard let rootViewController = window?.rootViewController else {
            return
        }

        Actito.shared.pushUI().presentAction(action, for: notification, in: rootViewController)
    }

    internal func actito(_: ActitoPush, didOpenUnknownNotification _: [AnyHashable: Any]) {
        Logger.main.info("Actito: opened unknown notification")
    }

    internal func actito(_: ActitoPush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {
        Logger.main.info("Actito: opened unknown action")
    }
}

extension AppDelegate: ActitoPushUIDelegate {
    internal func actito(_: ActitoPushUI, willPresentNotification notification: ActitoNotification) {
        Logger.main.info("Actito: will present notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didPresentNotification notification: ActitoNotification) {
        Logger.main.info("Actito: did present notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didFailToPresentNotification notification: ActitoNotification) {
        Logger.main.error("Actito: did fail to present notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didFinishPresentingNotification notification: ActitoNotification) {
        Logger.main.info("Actito: did finish presenting notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didClickURL url: URL, in notification: ActitoNotification) {
        Logger.main.info("Actito: did click url '\(url)' in notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, willExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification) {
        Logger.main.info("Actito: will execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification) {
        Logger.main.info("Actito: did execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didNotExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification) {
        Logger.main.info("Actito: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didFailToExecuteAction action: ActitoNotification.Action, for notification: ActitoNotification, error _: Error?) {
        Logger.main.error("Actito: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func actito(_: ActitoPushUI, didReceiveCustomAction _: URL, in _: ActitoNotification.Action, for _: ActitoNotification) {
        //
    }
}

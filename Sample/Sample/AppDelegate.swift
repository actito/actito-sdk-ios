//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoGeoKit
import ActitoInAppMessagingKit
import ActitoInboxKit
import ActitoKit
import ActitoPushKit
import ActitoPushUIKit
import ActitoScannablesKit
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

        // Enable Proxyman debugging.
        // Atlantis.start()

        if #available(iOS 14.0, *) {
            Actito.shared.push().presentationOptions = [.banner, .badge, .sound]
        } else {
            Actito.shared.push().presentationOptions = [.alert, .badge, .sound]
        }

        Actito.shared.delegate = self
        Actito.shared.push().delegate = self
        Actito.shared.pushUI().delegate = self
        Actito.shared.inAppMessaging().delegate = self
        Actito.shared.inbox().delegate = self
        Actito.shared.geo().delegate = self
        Actito.shared.scannables().delegate = self

        Task {
            do {
                try await Actito.shared.launch()
            } catch {
                Logger.main.error("Failed to launch Actito. \(error)")
            }
        }

        if #available(iOS 16.1, *) {
            LiveActivitiesController.shared.startMonitoring()
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

        registerUser()

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

    private func registerUser() {
        guard let user = SampleUser.loadFromPlist() else {
            return
        }

        let userId = user.userId.isEmpty ? nil : user.userId
        let userName = user.userName.isEmpty ? nil : user.userName

        Task {
            do {
                Logger.main.info("Registering device")
                try await Actito.shared.device().updateUser(userId: userId, userName: userName)
                Logger.main.info("Device registered successfully")
            } catch {
                Logger.main.error("Failed to registered device: \(error)")
            }
        }
    }
}

extension AppDelegate: ActitoPushDelegate {
    internal func actito(_: ActitoPush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.main.error("Actito: failed to register for remote notifications: \(error)")
    }

    internal func actito(_ actitoPush: any ActitoPush, didChangeSubscription subscription: ActitoPushSubscription?) {
        Logger.main.info("Notification center subscription changed: \(String(describing: subscription))")
    }

    internal func actito(_: ActitoPush, didChangeNotificationSettings allowedUI: Bool) {
        Logger.main.info("Notification center allowedUI changed: \(allowedUI)")
    }

    internal func actito(_: ActitoPush, didReceiveSystemNotification notification: ActitoSystemNotification) {
        Logger.main.info("Actito: received a system notification: \(String(describing: notification))")
    }

    internal func actito(_: ActitoPush, didReceiveNotification notification: ActitoNotification, deliveryMechanism: ActitoNotificationDeliveryMechanism) {
        Logger.main.info("Actito: received a notification: \(String(describing: notification))")
        Logger.main.info("Actito: received notification delivery mechanism: \(deliveryMechanism.rawValue)")
    }

    internal func actito(_: ActitoPush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        Logger.main.info("Actito: received an unknown notification: \(userInfo)")
    }

    internal func actito(_: ActitoPush, shouldOpenSettings _: ActitoNotification?) {
        Logger.main.info("Actito: should open notification settings")
    }

    internal func actito(_: ActitoPush, didOpenNotification notification: ActitoNotification) {
        UIApplication.shared.present(notification)
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

extension AppDelegate: ActitoInboxDelegate {
    internal func actito(_: ActitoInbox, didUpdateInbox items: [ActitoInboxItem]) {
        Logger.main.info("Delegate inbox update. Total = \(items.count)")
    }

    internal func actito(_: ActitoInbox, didUpdateBadge badge: Int) {
        Logger.main.info("Delegate badge update. Unread = \(badge)")
    }
}

extension AppDelegate: ActitoGeoDelegate {
    internal func actito(_: ActitoGeo, didUpdateLocations locations: [ActitoLocation]) {
        Logger.main.info("Locations updated = \(locations)")
    }

    internal func actito(_: ActitoGeo, didFailWith error: Error) {
        Logger.main.error("Location services failed = \(error)")
    }

    internal func actito(_: ActitoGeo, didStartMonitoringFor region: ActitoRegion) {
        Logger.main.info("Started monitoring region = \(region.name)")
    }

    internal func actito(_: ActitoGeo, didStartMonitoringFor beacon: ActitoBeacon) {
        Logger.main.info("Started monitoring beacon = \(beacon.name)")
    }

    internal func actito(_: ActitoGeo, monitoringDidFailFor region: ActitoRegion, with error: Error) {
        Logger.main.error("Failed to monitor region = \(region.name)\n\(error)")
    }

    internal func actito(_: ActitoGeo, monitoringDidFailFor beacon: ActitoBeacon, with error: Error) {
        Logger.main.error("Failed to monitor beacon = \(beacon.name)\n\(error)")
    }

    internal func actito(_: ActitoGeo, didDetermineState state: CLRegionState, for region: ActitoRegion) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        Logger.main.info("State for region '\(region.name)' = \(stateStr)")
    }

    internal func actito(_: ActitoGeo, didDetermineState state: CLRegionState, for beacon: ActitoBeacon) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        Logger.main.info("State for beacon '\(beacon.name)' = \(stateStr)")
    }

    internal func actito(_: ActitoGeo, didEnter region: ActitoRegion) {
        Logger.main.info("On region enter = \(region.name)")
    }

    internal func actito(_: ActitoGeo, didEnter beacon: ActitoBeacon) {
        Logger.main.info("On beacon enter = \(beacon.name)")
    }

    internal func actito(_: ActitoGeo, didExit region: ActitoRegion) {
        Logger.main.info("On region exit = \(region.name)")
    }

    internal func actito(_: ActitoGeo, didExit beacon: ActitoBeacon) {
        Logger.main.info("On beacon exit = \(beacon.name)")
    }

    internal func actito(_: ActitoGeo, didVisit visit: ActitoVisit) {
        Logger.main.info("On visit = \(String(describing: visit))")
    }

    internal func actito(_: ActitoGeo, didUpdateHeading heading: ActitoHeading) {
        Logger.main.info("On heading updated = \(String(describing: heading))")
    }

    internal func actito(_: ActitoGeo, didRange beacons: [ActitoBeacon], in region: ActitoRegion) {
        if !beacons.isEmpty {
            Logger.main.info("On ranging beacons: \(beacons.map(\.name).joined(separator: " "))")
        }

        NotificationCenter.default.post(
            name: .beaconsRanged,
            object: nil,
            userInfo: [
                "region": region,
                "beacons": beacons,
            ]
        )
    }

    internal func actito(_: ActitoGeo, didFailRangingFor region: ActitoRegion, with _: Error) {
        Logger.main.error("Failed to range beacons for region = \(region.name)")
    }
}

extension AppDelegate: ActitoInAppMessagingDelegate {
    internal func actito(_: ActitoInAppMessaging, didPresentMessage message: ActitoInAppMessage) {
        Logger.main.info("in-app message presented = \(String(describing: message))")
    }

    internal func actito(_: ActitoInAppMessaging, didFinishPresentingMessage message: ActitoInAppMessage) {
        Logger.main.info("in-app message finished presenting = \(String(describing: message))")
    }

    internal func actito(_: ActitoInAppMessaging, didFailToPresentMessage message: ActitoInAppMessage) {
        Logger.main.error("in-app message failed to present = \(String(describing: message))")
    }

    internal func actito(_: ActitoInAppMessaging, didExecuteAction action: ActitoInAppMessage.Action, for message: ActitoInAppMessage) {
        Logger.main.info("in-app message action executed = \(String(describing: action))")
        Logger.main.info("for message = \(String(describing: message))")
    }

    internal func actito(_: ActitoInAppMessaging, didFailToExecuteAction action: ActitoInAppMessage.Action, for message: ActitoInAppMessage, error _: Error?) {
        Logger.main.error("in-app message action failed to execute = \(String(describing: action))")
        Logger.main.error("for message = \(String(describing: message))")
    }
}

extension AppDelegate: ActitoScannablesDelegate {
    internal func actito(_: ActitoScannables, didDetectScannable scannable: ActitoScannable) {
        guard let notification = scannable.notification else {
            Logger.main.info("Cannot present a scannable without a notification.")
            return
        }

        UIApplication.shared.present(notification)
    }

    internal func actito(_: ActitoScannables, didInvalidateScannerSession error: Error) {
        Logger.main.error("Scannable session invalidated: \(error)")
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        let allowedUI = UserDefaults.standard.bool(forKey: "notificareAllowedUI")

        LocalStorage.allowedUI = allowedUI
        LocalStorage.remoteNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificareRegisteredForNotifications")

        if allowedUI {
            // Prevent the lib from sending the push registration event for existing devices.
            LocalStorage.firstRegistration = false
        }
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        if Actito.shared.options!.userNotificationCenterDelegateEnabled {
            logger.debug("Actito will set itself as the UNUserNotificationCenter delegate.")
            Actito.shared.pushImplementation().notificationCenter.delegate = Actito.shared.pushImplementation().notificationCenterDelegate
        } else {
            logger.warning("""
            Please configure your plist settings to allow Actito to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Actito.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = ActitoSwizzler.addInterceptor(Actito.shared.pushImplementation().applicationDelegateInterceptor)

        // Listen to 'application did become active'.
        NotificationCenter.default.upsertObserver(
            Actito.shared.pushImplementation(),
            selector: #selector(Actito.shared.pushImplementation().onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        LocalStorage.clear()

        Actito.shared.pushImplementation()._subscriptionStream.value = LocalStorage.subscription
        Actito.shared.pushImplementation()._allowedUIStream.value = LocalStorage.allowedUI
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if Actito.shared.pushImplementation().hasRemoteNotificationsEnabled {
            logger.debug("Enabling remote notifications automatically.")
            try await Actito.shared.pushImplementation().updateDeviceSubscription()

            if await Actito.shared.pushImplementation().hasNotificationPermission() {
                await Actito.shared.pushImplementation().reloadActionCategories()
            }
        }
    }

    internal func unlaunch() async throws {
        // Unregister from APNS
        await UIApplication.shared.unregisterForRemoteNotifications()
        logger.info("Unregistered from APNS.")

        // Reset local storage
        LocalStorage.remoteNotificationsEnabled = false
        LocalStorage.firstRegistration = true

        Actito.shared.pushImplementation().transport = nil
        Actito.shared.pushImplementation().subscription = nil
        Actito.shared.pushImplementation().allowedUI = false

        Actito.shared.pushImplementation().notifySubscriptionUpdated(nil)
        Actito.shared.pushImplementation().notifyAllowedUIUpdated(false)
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

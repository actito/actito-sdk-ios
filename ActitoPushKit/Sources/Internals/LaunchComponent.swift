//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal let implementation = ActitoPushImpl.instance

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
            implementation.notificationCenter.delegate = implementation.notificationCenterDelegate
        } else {
            logger.warning("""
            Please configure your plist settings to allow Actito to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Actito.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = ActitoSwizzler.addInterceptor(implementation.applicationDelegateInterceptor)

        // Listen to 'application did become active'.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        LocalStorage.clear()

        implementation._subscriptionStream.value = LocalStorage.subscription
        implementation._allowedUIStream.value = LocalStorage.allowedUI
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if implementation.hasRemoteNotificationsEnabled {
            logger.debug("Enabling remote notifications automatically.")
            try await implementation.updateDeviceSubscription()

            if await implementation.hasNotificationPermission() {
                await implementation.reloadActionCategories()
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

        implementation.transport = nil
        implementation.subscription = nil
        implementation.allowedUI = false

        implementation.notifySubscriptionUpdated(nil)
        implementation.notifyAllowedUIUpdated(false)
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

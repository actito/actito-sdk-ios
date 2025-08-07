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
            Actito.shared.push().notificationCenter.delegate = Actito.shared.push().notificationCenterDelegate
        } else {
            logger.warning("""
            Please configure your plist settings to allow Actito to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Actito.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = ActitoSwizzler.addInterceptor(Actito.shared.push().applicationDelegateInterceptor)

        // Listen to 'application did become active'.
        NotificationCenter.default.upsertObserver(
            Actito.shared.push(),
            selector: #selector(Actito.shared.push().onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        LocalStorage.clear()

        Actito.shared.push()._subscriptionStream.value = LocalStorage.subscription
        Actito.shared.push()._allowedUIStream.value = LocalStorage.allowedUI
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if Actito.shared.push().hasRemoteNotificationsEnabled {
            logger.debug("Enabling remote notifications automatically.")
            try await Actito.shared.push().updateDeviceSubscription()

            if await Actito.shared.push().hasNotificationPermission() {
                await Actito.shared.push().reloadActionCategories()
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

        Actito.shared.push().transport = nil
        Actito.shared.push().subscription = nil
        Actito.shared.push().allowedUI = false

        Actito.shared.push().notifySubscriptionUpdated(nil)
        Actito.shared.push().notifyAllowedUIUpdated(false)
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

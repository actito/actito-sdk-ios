//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal class DeviceLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = DeviceLaunchComponent()

    internal let implementation = ActitoDeviceModuleImpl.instance

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        // Listen to timezone changes
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.updateDeviceTimezone),
            name: UIApplication.significantTimeChangeNotification,
            object: nil
        )

        // Listen to language changes
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.updateDeviceLanguage),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )

        // Listen to 'background refresh status' changes
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.updateDeviceBackgroundAppRefresh),
            name: UIApplication.backgroundRefreshStatusDidChangeNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        try await implementation.upgradeToLongLivedDeviceWhenNeeded()

        if let storedDevice = implementation.storedDevice {
            let isApplicationUpgrade = storedDevice.appVersion != Bundle.main.applicationVersion

            do {
                try await implementation.updateDevice()
            } catch {
                if case let ActitoNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                    logger.warning("The device was removed from Actito. Recovering...")

                    logger.debug("Resetting local storage.")
                    try await implementation.resetLocalStorage()

                    logger.debug("Creating a new device")
                    try await implementation.createDevice()
                    implementation.hasPendingDeviceRegistrationEvent = true

                    // Ensure a session exists for the current device.
                    try await ActitoInternals.Module.session.klass?.instance.launch()

                    // We will log the Install & Registration events here since this will execute only one time at the start.
                    try? await Actito.shared.eventsImplementation().logApplicationInstall()
                    try? await Actito.shared.eventsImplementation().logApplicationRegistration()

                    return
                }

                throw error
            }

            // Ensure a session exists for the current device.
            try await ActitoInternals.Module.session.klass?.instance.launch()

            if isApplicationUpgrade {
                // It's not the same version, let's log it as an upgrade.
                logger.debug("New version detected")
                try? await Actito.shared.eventsImplementation().logApplicationUpgrade()
            }
        } else {
            logger.debug("New install detected")

            try await implementation.createDevice()
            implementation.hasPendingDeviceRegistrationEvent = true

            // Ensure a session exists for the current device.
            try await ActitoInternals.Module.session.klass?.instance.launch()

            // We will log the Install & Registration events here since this will execute only one time at the start.
            try? await Actito.shared.eventsImplementation().logApplicationInstall()
            try? await Actito.shared.eventsImplementation().logApplicationRegistration()
        }
    }

    internal func postLaunch() async throws {
        if
            let storedDevice = implementation.storedDevice, implementation.hasPendingDeviceRegistrationEvent == true
        {
            DispatchQueue.main.async {
                Actito.shared.delegate?.actito(Actito.shared, didRegisterDevice: storedDevice.asPublic())
            }
        }
    }

    internal func unlaunch() async throws {
        // no-op
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

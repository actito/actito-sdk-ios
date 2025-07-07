//
// Copyright (c) 2025 Actito. All rights reserved.
//

import UIKit

internal class DeviceLaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = DeviceLaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        // Listen to timezone changes
        NotificationCenter.default.upsertObserver(
            Actito.shared.deviceImplementation(),
            selector: #selector(Actito.shared.deviceImplementation().updateDeviceTimezone),
            name: UIApplication.significantTimeChangeNotification,
            object: nil
        )

        // Listen to language changes
        NotificationCenter.default.upsertObserver(
            Actito.shared.deviceImplementation(),
            selector: #selector(Actito.shared.deviceImplementation().updateDeviceLanguage),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )

        // Listen to 'background refresh status' changes
        NotificationCenter.default.upsertObserver(
            Actito.shared.deviceImplementation(),
            selector: #selector(Actito.shared.deviceImplementation().updateDeviceBackgroundAppRefresh),
            name: UIApplication.backgroundRefreshStatusDidChangeNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        // no-op
    }

    internal func launch() async throws {
        try await Actito.shared.deviceImplementation().upgradeToLongLivedDeviceWhenNeeded()

        if let storedDevice = Actito.shared.deviceImplementation().storedDevice {
            let isApplicationUpgrade = storedDevice.appVersion != Bundle.main.applicationVersion

            do {
                try await Actito.shared.deviceImplementation().updateDevice()
            } catch {
                if case let ActitoNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                    logger.warning("The device was removed from Actito. Recovering...")

                    logger.debug("Resetting local storage.")
                    try await Actito.shared.deviceImplementation().resetLocalStorage()

                    logger.debug("Creating a new device")
                    try await Actito.shared.deviceImplementation().createDevice()
                    Actito.shared.deviceImplementation().hasPendingDeviceRegistrationEvent = true

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

            try await Actito.shared.deviceImplementation().createDevice()
            Actito.shared.deviceImplementation().hasPendingDeviceRegistrationEvent = true

            // Ensure a session exists for the current device.
            try await ActitoInternals.Module.session.klass?.instance.launch()

            // We will log the Install & Registration events here since this will execute only one time at the start.
            try? await Actito.shared.eventsImplementation().logApplicationInstall()
            try? await Actito.shared.eventsImplementation().logApplicationRegistration()
        }
    }

    internal func postLaunch() async throws {
        if
            let storedDevice = Actito.shared.deviceImplementation().storedDevice, Actito.shared.deviceImplementation().hasPendingDeviceRegistrationEvent == true
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

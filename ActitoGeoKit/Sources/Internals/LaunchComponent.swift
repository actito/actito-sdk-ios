//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import CoreLocation
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal let implementation = ActitoGeoImpl.instance

    internal func migrate() {
        LocalStorage.locationServicesEnabled = UserDefaults.standard.bool(forKey: "notificareAllowedLocationServices")
        LocalStorage.bluetoothEnabled = UserDefaults.standard.bool(forKey: "notificareBluetoothON")
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        implementation.locationManager = CLLocationManager()
        implementation.locationManager?.delegate = implementation
        implementation.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
            logger.debug("Using Background Location Updates background mode.")
            implementation.locationManager.allowsBackgroundLocationUpdates = true
        }

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to application will resign active events.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onApplicationWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        implementation.stopMonitoringLocationUpdates()
        implementation.stopMonitoringGeofences()

        LocalStorage.clear()
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if implementation.hasLocationServicesEnabled {
            logger.debug("Enabling locations updates automatically.")
            implementation.enableLocationUpdates()
        }
    }

    internal func unlaunch() async throws {
        LocalStorage.locationServicesEnabled = false

        implementation.stopMonitoringGeofences()
        implementation.stopMonitoringLocationUpdates()

        try await implementation.clearDeviceLocation()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

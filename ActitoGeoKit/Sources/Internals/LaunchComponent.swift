//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import CoreLocation
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        LocalStorage.locationServicesEnabled = UserDefaults.standard.bool(forKey: "notificareAllowedLocationServices")
        LocalStorage.bluetoothEnabled = UserDefaults.standard.bool(forKey: "notificareBluetoothON")
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        Actito.shared.geoImplementation().locationManager = CLLocationManager()
        Actito.shared.geoImplementation().locationManager?.delegate = Actito.shared.geoImplementation()
        Actito.shared.geoImplementation().locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
            logger.debug("Using Background Location Updates background mode.")
            Actito.shared.geoImplementation().locationManager.allowsBackgroundLocationUpdates = true
        }

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.geoImplementation(),
            selector: #selector(Actito.shared.geoImplementation().onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to application will resign active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.geoImplementation(),
            selector: #selector(Actito.shared.geoImplementation().onApplicationWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        Actito.shared.geoImplementation().stopMonitoringLocationUpdates()
        Actito.shared.geoImplementation().stopMonitoringGeofences()

        LocalStorage.clear()
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if Actito.shared.geoImplementation().hasLocationServicesEnabled {
            logger.debug("Enabling locations updates automatically.")
            Actito.shared.geoImplementation().enableLocationUpdates()
        }
    }

    internal func unlaunch() async throws {
        LocalStorage.locationServicesEnabled = false

        Actito.shared.geoImplementation().stopMonitoringGeofences()
        Actito.shared.geoImplementation().stopMonitoringLocationUpdates()

        try await Actito.shared.geoImplementation().clearDeviceLocation()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

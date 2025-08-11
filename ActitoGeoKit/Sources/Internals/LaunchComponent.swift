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

        Actito.shared.geo().locationManager = CLLocationManager()
        Actito.shared.geo().locationManager?.delegate = Actito.shared.geo()
        Actito.shared.geo().locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
            logger.debug("Using Background Location Updates background mode.")
            Actito.shared.geo().locationManager.allowsBackgroundLocationUpdates = true
        }

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.geo(),
            selector: #selector(Actito.shared.geo().onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to application will resign active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.geo(),
            selector: #selector(Actito.shared.geo().onApplicationWillResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        Actito.shared.geo().stopMonitoringLocationUpdates()
        Actito.shared.geo().stopMonitoringGeofences()

        LocalStorage.clear()
    }

    internal func launch() async throws {
        // no-op
    }

    internal func postLaunch() async throws {
        if Actito.shared.geo().hasLocationServicesEnabled {
            logger.debug("Enabling locations updates automatically.")
            Actito.shared.geo().enableLocationUpdates()
        }
    }

    internal func unlaunch() async throws {
        LocalStorage.locationServicesEnabled = false

        Actito.shared.geo().stopMonitoringGeofences()
        Actito.shared.geo().stopMonitoringLocationUpdates()

        try await Actito.shared.geo().clearDeviceLocation()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

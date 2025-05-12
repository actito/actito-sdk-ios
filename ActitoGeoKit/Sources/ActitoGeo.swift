//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

public protocol ActitoGeo: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles geo events
    ///
    /// This property allows setting a delegate conforming to ``ActitoGeoDelegate`` to respond to various geo events,
    /// such as location updates, region monitoring events, and beacon proximity events.
    var delegate: ActitoGeoDelegate? { get set }

    /// Indicates whether location services are enabled.
    ///
    /// This property returns `true` if the location services are enabled by the application, and `false`
    /// otherwise.
    var hasLocationServicesEnabled: Bool { get }

    /// Indicates whether Bluetooth is enabled.
    ///
    /// This property returns `true` if Bluetooth is enabled and available for beacon detection and ranging, and `false`
    /// otherwise.
    var hasBluetoothEnabled: Bool { get }

    /// Provides a list of regions currently being monitored.
    ///
    /// This property returns a list of ``ActitoRegion`` objects representing the geographical regions being actively
    /// monitored for entry and exit events.
    var monitoredRegions: [ActitoRegion] { get }

    /// Provides a list of regions the user has entered.
    ///
    /// This property returns a list of ``ActitoRegion`` objects representing the regions that the user has entered and
    /// not yet exited.
    var enteredRegions: [ActitoRegion] { get }

    // MARK: Methods

    /// Enables location updates, activating location tracking, region monitoring, and beacon detection.
    ///
    /// The behavior varies based on granted permissions:
    /// - **Permission denied**: Clears the device's location information.
    /// - **While In Use permission granted**: Tracks location only while the app is in use.
    /// - **Always permissions granted**: Enables geofencing and beacon detection.
    func enableLocationUpdates()

    /// Disables location updates.
    ///
    /// This method stops receiving location updates, monitoring regions, and detecting nearby beacons.
    func disableLocationUpdates()
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import CoreLocation
import Foundation

public protocol ActitoGeoDelegate: AnyObject {
    /// Called when the device's location is updated.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - locations: A list of the updated ``ActitoLocation``
    func actito(_ actitoGeo: ActitoGeo, didUpdateLocations locations: [ActitoLocation])

    /// Called when the location services failed.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - error: The error associated to the location services failure.
    func actito(_ actitoGeo: ActitoGeo, didFailWith error: Error)

    /// Called when the device starts monitoring a ``ActitoRegion``.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - region: The ``ActitoRegion`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didStartMonitoringFor region: ActitoRegion)

    /// Called when the device starts monitoring a ``ActitoBeacon``.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - beacon: The ``ActitoBeacon`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didStartMonitoringFor beacon: ActitoBeacon)

    /// Called when monitoring a ``ActitoRegion`` fails.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - region: The ``ActitoRegion`` being monitored.
    ///   - error: The error associated to the location services failure.
    func actito(_ actitoGeo: ActitoGeo, monitoringDidFailFor region: ActitoRegion, with error: Error)

    /// Called when monitoring a ``ActitoBeacon`` fails.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - beacon: The ``ActitoBeacon`` being monitored.
    ///   - error: The error associated to the location services failure.
    func actito(_ actitoGeo: ActitoGeo, monitoringDidFailFor beacon: ActitoBeacon, with error: Error)

    /// Called when the state of a monitored region is determined.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - state: The determined state of the region.
    ///   - region: The ``ActitoRegion`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didDetermineState state: CLRegionState, for region: ActitoRegion)

    /// Called when the state of a monitored beacon is determined.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - state: The determined state of the beacon.
    ///   - beacon: The ``ActitoBeacon`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didDetermineState state: CLRegionState, for beacon: ActitoBeacon)

    /// Called when the device enters a monitored region.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - region: The ``ActitoRegion`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didEnter region: ActitoRegion)

    /// Called when the device enters a monitored beacon.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - beacon: The ``ActitoBeacon`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didEnter beacon: ActitoBeacon)

    /// Called when the device exits a monitored region.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - region: The ``ActitoRegion`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didExit region: ActitoRegion)

    /// Called when the device exits a monitored beacon.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - beacon: The ``ActitoBeacon`` being monitored.
    func actito(_ actitoGeo: ActitoGeo, didExit beacon: ActitoBeacon)

    /// Called when the device registers a location visit.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - visit: The ``ActitoVisit`` object representing the details of the visit.
    func actito(_ actitoGeo: ActitoGeo, didVisit visit: ActitoVisit)

    /// Called when there is an update to the device’s heading.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - heading: The ``ActitoHeading`` object containing details of the updated heading.
    func actito(_ actitoGeo: ActitoGeo, didUpdateHeading heading: ActitoHeading)

    /// Called when the device detects or updates proximity to beacons within a specified region.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - beacons: A list of detected ``ActitoBeacon``.
    ///   - region: The ``ActitoRegion`` where the beacons are being ranged.
    func actito(_ actitoGeo: ActitoGeo, didRange beacons: [ActitoBeacon], in region: ActitoRegion)

    /// Called when beacon ranging fails within a specified region.
    ///
    /// - Parameters:
    ///   - actitoGeo: The ActitoGeo object instance.
    ///   - region: The ``ActitoRegion`` where the beacons are being ranged.
    ///   - error: The error associated with the failure.
    func actito(_ actitoGeo: ActitoGeo, didFailRangingFor region: ActitoRegion, with error: Error)
}

extension ActitoGeoDelegate {
    public func actito(_: ActitoGeo, didUpdateLocations _: [ActitoLocation]) {}

    public func actito(_: ActitoGeo, didFailWith _: Error) {}

    public func actito(_: ActitoGeo, didStartMonitoringFor _: ActitoRegion) {}

    public func actito(_: ActitoGeo, didStartMonitoringFor _: ActitoBeacon) {}

    public func actito(_: ActitoGeo, monitoringDidFailFor _: ActitoRegion, with _: Error) {}

    public func actito(_: ActitoGeo, monitoringDidFailFor _: ActitoBeacon, with _: Error) {}

    public func actito(_: ActitoGeo, didDetermineState _: CLRegionState, for _: ActitoRegion) {}

    public func actito(_: ActitoGeo, didDetermineState _: CLRegionState, for _: ActitoBeacon) {}

    public func actito(_: ActitoGeo, didEnter _: ActitoRegion) {}

    public func actito(_: ActitoGeo, didEnter _: ActitoBeacon) {}

    public func actito(_: ActitoGeo, didExit _: ActitoRegion) {}

    public func actito(_: ActitoGeo, didExit _: ActitoBeacon) {}

    public func actito(_: ActitoGeo, didVisit _: ActitoVisit) {}

    public func actito(_: ActitoGeo, didUpdateHeading _: ActitoHeading) {}

    public func actito(_: ActitoGeo, didRange _: [ActitoBeacon], in _: ActitoRegion) {}

    public func actito(_: ActitoGeo, didFailRangingFor _: ActitoRegion, with _: Error) {}
}

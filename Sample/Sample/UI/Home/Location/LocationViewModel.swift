//
// Copyright (c) 2026 Actito. All rights reserved.
//

import ActitoGeoKit
import ActitoKit
import Combine
import CoreLocation
import Foundation
import OSLog

private let REQUESTED_LOCATION_ALWAYS_KEY = "com.actito.geo.requested_location_always"

@MainActor
internal class LocationViewModel: NSObject, ObservableObject, @MainActor CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var requestedPermission: LocationPermissionGroup?
    private var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    @Published internal var hasLocationAndPermission = Actito.shared.geo().hasLocationServicesEnabled
    @Published internal private(set) var hasLocationEnabled = false
    @Published internal private(set) var locationPermission: LocationPermissionStatus? = nil
    @Published internal private(set) var hasBluetoothEnabled = false

    @Published internal private(set) var monitoredRegions: [ActitoRegion] = Actito.shared.geo().monitoredRegions
    @Published internal private(set) var enteredRegions: [ActitoRegion] = Actito.shared.geo().enteredRegions
    @Published internal private(set) var rangedBeacons: [ActitoBeacon] = []

    private var cancellables = Set<AnyCancellable>()

    override internal init() {
        super.init()
        locationManager.delegate = self

        NotificationCenter.default
            .publisher(for: .locationUpdated)
            .sink { [weak self] _ in
                self?.monitoredRegions = Actito.shared.geo().monitoredRegions
            }
            .store(in: &cancellables)

        Publishers.Merge(
            NotificationCenter.default.publisher(for: .regionEntered),
            NotificationCenter.default.publisher(for: .regionExited)
        )
            .sink { [weak self] _ in
                self?.enteredRegions = Actito.shared.geo().enteredRegions
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: .beaconsRanged)
            .sink { [weak self] notification in
                guard let beacons = notification.userInfo?["beacons"] as? [ActitoBeacon] else {
                    return
                }

                self?.rangedBeacons = beacons
            }
            .store(in: &cancellables)

        checkLocationStatus()
    }

    private func checkLocationStatus() {
        let whenInUse = checkLocationPermissionStatus(permission: .locationWhenInUse)
        let always = checkLocationPermissionStatus(permission: .locationAlways)

        hasLocationAndPermission = whenInUse == .granted && Actito.shared.geo().hasLocationServicesEnabled
        hasLocationEnabled = Actito.shared.geo().hasLocationServicesEnabled
        hasBluetoothEnabled = Actito.shared.geo().hasBluetoothEnabled

        // Check location init

        switch whenInUse {
        case .granted:
            if always == .granted {
                locationPermission = LocationPermissionStatus.always
            } else {
                locationPermission = LocationPermissionStatus.whenInUse
            }
        case .notDetermined:
            locationPermission = LocationPermissionStatus.notDetermined
        case .restricted:
            locationPermission = LocationPermissionStatus.restricted
        case .permanentlyDenied:
            locationPermission = LocationPermissionStatus.permanentlyDenied
        }

        monitoredRegions = Actito.shared.geo().monitoredRegions
        enteredRegions = Actito.shared.geo().enteredRegions
    }

    internal func updateLocationServicesStatus(enabled: Bool) {
        Logger.main.info("Location Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            enableLocationUpdates()
        } else {
            Logger.main.info("Disabling location updates")
            Actito.shared.geo().disableLocationUpdates()
            checkLocationStatus()
        }
    }

    private func enableLocationUpdates(permissionGranted: LocationPermissionGroup? = nil) {
        switch permissionGranted {
        case .locationAlways:
            Actito.shared.geo().enableLocationUpdates()

        case .locationWhenInUse:
            Actito.shared.geo().enableLocationUpdates()
            _ = ensureAlwaysLocationPermissionGranted()

        case nil:
            if ensureWhenInUseLocationPermissionGranted() {
                Actito.shared.geo().enableLocationUpdates()
                _ = ensureAlwaysLocationPermissionGranted()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkLocationStatus()
        }
    }

    private func ensureWhenInUseLocationPermissionGranted() -> Bool {
        Logger.main.info("Checking location When in Use permission status")

        let whenInUsePermission = checkLocationPermissionStatus(permission: .locationWhenInUse)
        switch whenInUsePermission {
        case .permanentlyDenied, .restricted:
            Logger.main.info("Location When in Use is permanently denied")
            return false

        case .notDetermined:
            Logger.main.info("Location When in Use is not determined, requesting permission")
            requestLocationPermission(permission: .locationWhenInUse)
            return false

        case .granted:
            Logger.main.info("Location When in Use granted, enabling location updates")
            return true
        }
    }

    private func ensureAlwaysLocationPermissionGranted() -> Bool {
        Logger.main.info("Checking location Always permission status")
        let alwaysPermission = checkLocationPermissionStatus(permission: .locationAlways)

        switch alwaysPermission {
        case .permanentlyDenied, .restricted:
            Logger.main.info("Location Always permission is permanently denied")
            return false

        case .notDetermined:
            Logger.main.info("Location Always is not determined, requesting permission")
            requestLocationPermission(permission: .locationAlways)
            return false

        case .granted:
            Logger.main.info("Location Always permission is granted, enabling location updates")
            return true
        }
    }

    private func checkLocationPermissionStatus(permission: LocationPermissionGroup) -> LocationPermissionGroupStatus {
        if permission == .locationAlways {
            switch authorizationStatus {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_LOCATION_ALWAYS_KEY) ? .permanentlyDenied : .notDetermined
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .notDetermined
            }
        }

        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .notDetermined
        }
    }

    private func requestLocationPermission(permission: LocationPermissionGroup) {
        requestedPermission = permission

        if permission == .locationWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else if permission == .locationAlways {
            locationManager.requestAlwaysAuthorization()
            UserDefaults.standard.set(true, forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }
    }

    internal func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onAuthorizationStatusChange(status)
    }

    @available(iOS 14.0, *)
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationStatusChange(manager.authorizationStatus)
    }

    private func onAuthorizationStatusChange(_ authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .notDetermined {
            // When the user changes to "Ask Next Time" via the Settings app.
            UserDefaults.standard.removeObject(forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }

        if let requestedPermission = requestedPermission {
            self.requestedPermission = nil
            let status = checkLocationPermissionStatus(permission: requestedPermission)

            if status == .granted {
                Logger.main.info("\(requestedPermission.rawValue) permission request granted.")
                enableLocationUpdates(permissionGranted: requestedPermission)

                return
            } else {
                Logger.main.info("\(requestedPermission.rawValue) permission request denied.")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkLocationStatus()
        }
    }
}

extension LocationViewModel {
    internal enum LocationPermissionGroup: String, CaseIterable {
        case locationWhenInUse = "Location When in Use"
        case locationAlways = "Location Always"
    }

    internal enum LocationPermissionGroupStatus: CaseIterable {
        case notDetermined
        case granted
        case restricted
        case permanentlyDenied
    }

    internal enum LocationPermissionStatus: String, CaseIterable {
        case notDetermined = "permission_status_not_determined"
        case restricted = "permission_status_restricted"
        case permanentlyDenied = "permission_status_permanently_denied"
        case whenInUse = "permission_status_when_in_use"
        case always = "permission_status_always"

        internal var localized: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    }
}

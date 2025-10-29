//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

extension ActitoInternals.PushAPI.Payloads {
    internal struct UpdateDeviceLocation: Encodable {
        @EncodeNull internal var latitude: Double?
        @EncodeNull internal var longitude: Double?
        @EncodeNull internal var altitude: Double?
        @EncodeNull internal var locationAccuracy: Double?
        @EncodeNull internal var speed: Double?
        @EncodeNull internal var course: Double?
        @EncodeNull internal var country: String?
        @EncodeNull internal var floor: Int?
        @EncodeNull internal var locationServicesAuthStatus: ActitoGeo.AuthorizationMode?
        @EncodeNull internal var locationServicesAccuracyAuth: ActitoGeo.AccuracyMode?
    }

    internal struct RegionSession: Codable, Sendable {
        internal let regionId: String
        internal let start: Date
        internal let end: Date?
        internal let locations: [ActitoLocation]
    }

    internal struct RegionTrigger: Encodable {
        internal let deviceID: String
        internal let region: String
    }

    internal struct BeaconTrigger: Encodable {
        internal let deviceID: String
        internal let beacon: String
    }

    internal struct BluetoothStateUpdate: Encodable {
        internal let bluetoothEnabled: Bool
    }
}

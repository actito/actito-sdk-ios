//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreLocation
import Foundation

/// Represents a beacon configured in Actito.
///
/// An ``ActitoBeacon`` describes a proximity beacon that can be used to trigger
/// proximity-based events.
public struct ActitoBeacon: Codable, Hashable, Equatable, Sendable {
    /// Unique identifier of the beacon.
    public let id: String

    /// Human-readable name of the beacon.
    public let name: String

    /// Major value of the beacon.
    ///
    /// This value is used to group related beacons.
    public let major: Int

    /// Optional minor value of the beacon.
    ///
    /// When provided, this value identifies a specific beacon within a group.
    public let minor: Int?

    /// Indicates whether this beacon can be used in triggers.
    public let triggers: Bool

    /// Proximity level associated with the beacon.
    public internal(set) var proximity: Proximity = .unknown

    /// Constructor for ``ActitoBeacon``.
    public init(id: String, name: String, major: Int, minor: Int?, triggers: Bool, proximity: ActitoBeacon.Proximity = .unknown) {
        self.id = id
        self.name = name
        self.major = major
        self.minor = minor
        self.triggers = triggers
        self.proximity = proximity
    }

    /// Supported Proximity values.
    public enum Proximity: String, Codable, Equatable, Sendable {
        /// The proximity of the beacon or region cannot be determined.
        case unknown

        /// The beacon or region is very close to the device.
        case immediate

        /// The beacon or region is nearby.
        case near

        /// The beacon or region is far from the device.
        case far
    }
}

// Identifiable: ActitoBeacon
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoBeacon: Identifiable {}

// JSON: ActitoBeacon
extension ActitoBeacon {
    /// Serializes ``ActitoBeacon`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoBeacon`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito beacon.
    ///
    /// - Returns: A parsed ``ActitoBeacon`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoBeacon {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoBeacon.self, from: data)
    }
}

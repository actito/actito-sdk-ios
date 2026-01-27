//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreLocation
import Foundation

/// Represents a geographic location captured from a device.
///
/// An ``ActitoLocation`` contains latitude, longitude, altitude, movement, and
/// accuracy information, along with a timestamp indicating when the location was
/// recorded.
public struct ActitoLocation: Codable, Equatable, Sendable {
    /// Latitude of the location in decimal degrees.
    public let latitude: Double

    /// Longitude of the location in decimal degrees.
    public let longitude: Double

    /// Altitude of the location in meters above sea level.
    public let altitude: Double

    /// Direction of travel in degrees relative to true north.
    ///
    /// This value represents the device's course of movement.
    public let course: Double

    /// Speed of the device in meters per second.
    public let speed: Double

    /// Optional floor level of the location.
    ///
    /// This is typically used for indoor positioning systems.
    public let floor: Int?

    /// Horizontal accuracy of the location measurement in meters.
    public let horizontalAccuracy: Double

    /// Vertical accuracy of the location measurement in meters.
    public let verticalAccuracy: Double

    /// Timestamp indicating when the location was recorded.
    public let timestamp: Date

    /// Constructor for ``ActitoLocation``.
    public init(latitude: Double, longitude: Double, altitude: Double, course: Double, speed: Double, floor: Int?, horizontalAccuracy: Double, verticalAccuracy: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.course = course
        self.speed = speed
        self.floor = floor
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.timestamp = timestamp
    }
}

extension ActitoLocation {
    internal init(cl location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        course = location.course
        speed = location.speed
        floor = location.floor?.level
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
        timestamp = location.timestamp
    }
}

// JSON: ActitoLocation
extension ActitoLocation {
    /// Serializes ``ActitoLocation`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoLocation`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito location.
    ///
    /// - Returns: A parsed ``ActitoLocation`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoLocation {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoLocation.self, from: data)
    }
}

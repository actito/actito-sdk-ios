//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

/// Represents heading and orientation data captured from a device.
///
/// An ``ActitoHeading`` contains compass and motion sensor information that may be
/// used for location-aware features.
public struct ActitoHeading: Codable, Equatable, Sendable {
    /// Magnetic heading of the device in degrees.
    ///
    /// This value is relative to magnetic north.
    public let magneticHeading: Double

    /// True heading of the device in degrees.
    ///
    /// This value is relative to true north.
    public let trueHeading: Double

    /// Estimated accuracy of the heading measurement in degrees.
    public let headingAccuracy: Double

    /// X-axis component of the device's orientation vector.
    public let x: Double

    /// Y-axis component of the device's orientation vector.
    public let y: Double

    /// Z-axis component of the device's orientation vector.
    public let z: Double

    /// Timestamp indicating when the heading data was recorded.
    public let timestamp: Date

    /// Constructor for ``ActitoHeading``.
    public init(magneticHeading: Double, trueHeading: Double, headingAccuracy: Double, x: Double, y: Double, z: Double, timestamp: Date) {
        self.magneticHeading = magneticHeading
        self.trueHeading = trueHeading
        self.headingAccuracy = headingAccuracy
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}

// JSON: ActitoHeading
extension ActitoHeading {
    /// Serializes ``ActitoHeading`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoHeading`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito heading.
    ///
    /// - Returns: A parsed ``ActitoHeading`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoHeading {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoHeading.self, from: data)
    }
}

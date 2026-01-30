//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

/// Represents a recorded visit or stay at a specific location.
///
/// An ``ActitoVisit` captures the geographic coordinates of the location along
/// with the arrival and departure timestamps. This is typically used for location
/// tracking, analytics, or region-based engagement.
public struct ActitoVisit: Codable, Equatable, Sendable {
    /// Timestamp when the visit ended.
    public let departureDate: Date

    /// Timestamp when the visit started.
    public let arrivalDate: Date

    /// Latitude of the visited location in decimal degrees.
    public let latitude: Double

    /// Longitude of the visited location in decimal degrees.
    public let longitude: Double

    /// Constructor for ``ActitoVisit``.
    public init(departureDate: Date, arrivalDate: Date, latitude: Double, longitude: Double) {
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.latitude = latitude
        self.longitude = longitude
    }
}

// JSON: ActitoVisit
extension ActitoVisit {
    /// Serializes ``ActitoVisit`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoVisit`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito visit.
    ///
    /// - Returns: A parsed ``ActitoVisit`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoVisit {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoVisit.self, from: data)
    }
}

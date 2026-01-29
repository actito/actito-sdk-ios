//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

/// Represents a geographic region configured in Actito.
///
/// An ``ActitoRegion` defines a location-based area that can be used for proximity
/// detection, geofencing, or region-triggered actions.
/// Regions may be defined using simple or advanced geometries.
public struct ActitoRegion: Codable, Equatable, Sendable {
    /// Unique identifier of the region.
    public let id: String

    /// Human-readable name of the region.
    public let name: String

    /// Optional description of the region.
    public let description: String?

    /// Optional reference key associated with the region.
    public let referenceKey: String?

    /// Primary geometry defining the region.
    public let geometry: Geometry

    /// Optional advanced geometry defining complex region shapes.
    public let advancedGeometry: AdvancedGeometry?

    /// Optional major value associated with the region.
    ///
    /// This is typically used for beacon-based regions.
    public let major: Int?

    /// Distance from the device to the region in meters.
    public let distance: Double

    /// Time zone identifier associated with the region.
    public let timeZone: String

    /// Time zone offset of the region in hours relative to UTC.
    public let timeZoneOffset: Float

    /// Constructor for ``ActitoRegion``.
    public init(id: String, name: String, description: String?, referenceKey: String?, geometry: ActitoRegion.Geometry, advancedGeometry: ActitoRegion.AdvancedGeometry?, major: Int?, distance: Double, timeZone: String, timeZoneOffset: Float) {
        self.id = id
        self.name = name
        self.description = description
        self.referenceKey = referenceKey
        self.geometry = geometry
        self.advancedGeometry = advancedGeometry
        self.major = major
        self.distance = distance
        self.timeZone = timeZone
        self.timeZoneOffset = timeZoneOffset
    }

    /// Defines the basic geometry of an Actito region.
    public struct Geometry: Codable, Equatable, Sendable {
        /// Geometry type.
        public let type: String

        /// Coordinate defining the geometry's reference point.
        public let coordinate: Coordinate

        /// Constructor for ``Geometry``.
        public init(type: String, coordinate: ActitoRegion.Coordinate) {
            self.type = type
            self.coordinate = coordinate
        }
    }

    /// Defines an advanced geometry for complex region shapes.
    public struct AdvancedGeometry: Codable, Equatable, Sendable {
        /// Geometry type.
        public let type: String

        /// List of coordinates defining the geometry.
        public let coordinates: [Coordinate]

        /// Constructor for ``AdvancedGeometry``.
        public init(type: String, coordinates: [ActitoRegion.Coordinate]) {
            self.type = type
            self.coordinates = coordinates
        }
    }

    /// Represents a geographic coordinate.
    ///
    /// Coordinates are expressed in decimal degrees.
    public struct Coordinate: Codable, Equatable, Sendable {
        /// Latitude in decimal degrees.
        public let latitude: Double

        /// Longitude in decimal degrees.
        public let longitude: Double

        /// Constructor for ``Coordinate``.
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

// Identifiable: ActitoRegion
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoRegion: Identifiable {}

// JSON: ActitoRegion
extension ActitoRegion {
    /// Serializes ``ActitoRegion`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoRegion`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito region.
    ///
    /// - Returns: A parsed ``ActitoRegion`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoRegion {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoRegion.self, from: data)
    }
}

// JSON: ActitoRegion.Geometry
extension ActitoRegion.Geometry {
    /// Serializes ``Geometry`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Geometry`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the geometry.
    ///
    /// - Returns: A parsed ``Geometry`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoRegion.Geometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoRegion.Geometry.self, from: data)
    }
}

// JSON: ActitoRegion.AdvancedGeometry
extension ActitoRegion.AdvancedGeometry {
    /// Serializes ``AdvancedGeometry`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``AdvancedGeometry`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the advanced geometry
    ///
    /// - Returns: A parsed ``AdvancedGeometry`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoRegion.AdvancedGeometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoRegion.AdvancedGeometry.self, from: data)
    }
}

// JSON: ActitoRegion.Coordinate
extension ActitoRegion.Coordinate {
    /// Serializes ``Coordinate`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Coordinate`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the coordinate.
    ///
    /// - Returns: A parsed ``Coordinate`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoRegion.Coordinate {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoRegion.Coordinate.self, from: data)
    }
}

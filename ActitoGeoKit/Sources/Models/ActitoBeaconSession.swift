//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

/// Represents a session of detected beacons within a given region.
///
/// An ``ActitoBeaconSession`` tracks the start and end time of the session, the region it belongs to, and the list of detected beacons.
public struct ActitoBeaconSession: Codable, Equatable, Sendable {
    /// The unique identifier of the region associated with this session.
    public let regionId: String

    /// The timestamp when the session started.
    public let start: Date

    /// The timestamp when the session ended, or `null` if the session is ongoing.
    public let end: Date?

    /// The list of beacons detected during this session.
    public let beacons: [Beacon]

    /// Represents a single beacon detected during a session.
    public struct Beacon: Codable, Equatable, Sendable {
        /// Proximity level of the beacon (e.g., unknown, immediate, near, far).
        public let proximity: Int

        /// The major identifier of the beacon.
        public let major: Int

        /// The minor identifier of the beacon.
        public let minor: Int

        /// Optional location of the beacon when detected.
        public let location: Location?

        /// The time when the beacon was observed.
        public let timestamp: Date

        /// Represents the latitude and longitude of a beacon at the time it was detected.
        public struct Location: Codable, Equatable, Sendable {
            /// Latitude of the beacon in decimal degrees.
            public let latitude: Double

            /// Longitude of the beacon in decimal degrees.
            public let longitude: Double
        }
    }
}

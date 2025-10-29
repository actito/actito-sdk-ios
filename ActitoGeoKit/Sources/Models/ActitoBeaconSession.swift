//
// Copyright (c) 2025 Actito. All rights reserved.
//

import Foundation

public struct ActitoBeaconSession: Codable, Equatable, Sendable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let beacons: [Beacon]

    public struct Beacon: Codable, Equatable, Sendable {
        public let proximity: Int
        public let major: Int
        public let minor: Int
        public let location: Location?
        public let timestamp: Date

        public struct Location: Codable, Equatable, Sendable {
            public let latitude: Double
            public let longitude: Double
        }
    }
}

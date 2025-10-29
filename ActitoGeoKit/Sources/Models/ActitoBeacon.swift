//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreLocation
import Foundation

public struct ActitoBeacon: Codable, Hashable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let major: Int
    public let minor: Int?
    public let triggers: Bool
    public internal(set) var proximity: Proximity = .unknown

    public init(id: String, name: String, major: Int, minor: Int?, triggers: Bool, proximity: ActitoBeacon.Proximity = .unknown) {
        self.id = id
        self.name = name
        self.major = major
        self.minor = minor
        self.triggers = triggers
        self.proximity = proximity
    }

    public enum Proximity: String, Codable, Equatable, Sendable {
        case unknown
        case immediate
        case near
        case far
    }
}

// Identifiable: ActitoBeacon
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoBeacon: Identifiable {}

// JSON: ActitoBeacon
extension ActitoBeacon {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoBeacon {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoBeacon.self, from: data)
    }
}

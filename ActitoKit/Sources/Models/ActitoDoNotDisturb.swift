//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Defines a do-not-disturb time window for an Actito device.
///
/// During this period, notifications or communications may be suppressed.
public struct ActitoDoNotDisturb: Codable, Equatable, Sendable {
    /// Start time of the do-not-disturb period.
    public let start: ActitoTime

    /// End time of the do-not-disturb period.
    public let end: ActitoTime

    /// Constructor for ``ActitoDoNotDisturb``.
    public init(start: ActitoTime, end: ActitoTime) {
        self.start = start
        self.end = end
    }
}

// JSON: ActitoDoNotDisturb
extension ActitoDoNotDisturb {
    /// Serializes ``ActitoDoNotDisturb`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoDoNotDisturb`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito Do Not Disturb.
    ///
    /// - Returns: A parsed ``ActitoDoNotDisturb`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoDoNotDisturb {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDoNotDisturb.self, from: data)
    }
}

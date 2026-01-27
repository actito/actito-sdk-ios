//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents a dynamic link configuration in Actito.
///
/// A dynamic link defines a target destination that can be resolved or interpreted,
/// such as a deep link, in-app route, or external URL.
public struct ActitoDynamicLink: Codable, Equatable, Sendable {
    /// The target destination of the dynamic link.
    public let target: String

    /// Constructor for ``ActitoDynamicLink``.
    public init(target: String) {
        self.target = target
    }
}

// JSON: ActitoDynamicLink
extension ActitoDynamicLink {
    /// Serializes ``ActitoDynamicLink`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoDynamicLink`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito Dynamic Link
    ///
    /// - Returns: A parsed ``ActitoDynamicLink`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoDynamicLink {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDynamicLink.self, from: data)
    }
}

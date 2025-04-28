//
// Copyright (c) 2025 Actito. All rights reserved.
//
import ActitoUtilitiesKit

public struct ActitoDynamicLink: Codable, Equatable {
    public let target: String

    public init(target: String) {
        self.target = target
    }
}

// JSON: ActitoDynamicLink
extension ActitoDynamicLink {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoDynamicLink {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDynamicLink.self, from: data)
    }
}

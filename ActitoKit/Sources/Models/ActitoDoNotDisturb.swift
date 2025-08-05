//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public struct ActitoDoNotDisturb: Codable, Equatable, Sendable {
    public let start: ActitoTime
    public let end: ActitoTime

    public init(start: ActitoTime, end: ActitoTime) {
        self.start = start
        self.end = end
    }
}

// JSON: ActitoDoNotDisturb
extension ActitoDoNotDisturb {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoDoNotDisturb {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDoNotDisturb.self, from: data)
    }
}

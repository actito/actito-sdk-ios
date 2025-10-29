//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

public struct ActitoPushSubscription: Codable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

// JSON: ActitoPushSubscription
extension ActitoPushSubscription {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoPushSubscription {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPushSubscription.self, from: data)
    }
}

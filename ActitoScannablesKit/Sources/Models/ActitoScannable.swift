//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit

public struct ActitoScannable: Codable, Equatable {
    public let id: String
    public let name: String
    public let tag: String
    public let type: String
    public let notification: ActitoNotification?

    public init(id: String, name: String, tag: String, type: String, notification: ActitoNotification?) {
        self.id = id
        self.name = name
        self.tag = tag
        self.type = type
        self.notification = notification
    }
}

// Identifiable: ActitoScannable
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoScannable: Identifiable {}

// JSON: ActitoScannable
extension ActitoScannable {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoScannable {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoScannable.self, from: data)
    }
}

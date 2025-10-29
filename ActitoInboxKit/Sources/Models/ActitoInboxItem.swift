//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit

public struct ActitoInboxItem: Codable, Equatable, Sendable {
    public let id: String
    public let notification: ActitoNotification
    public let time: Date
    public let opened: Bool
    public let expires: Date?

    public init(id: String, notification: ActitoNotification, time: Date, opened: Bool, expires: Date?) {
        self.id = id
        self.notification = notification
        self.time = time
        self.opened = opened
        self.expires = expires
    }
}

// Identifiable: ActitoInboxItem
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoInboxItem: Identifiable {}

// JSON: ActitoInboxItem
extension ActitoInboxItem {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInboxItem.self, from: data)
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

public struct ActitoUserInboxItem: Codable, Equatable, Sendable {
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

// Identifiable: ActitoUserInboxItem
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoUserInboxItem: Identifiable {}

// JSON: ActitoUserInboxItem
extension ActitoUserInboxItem {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoUserInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoUserInboxItem.self, from: data)
    }
}

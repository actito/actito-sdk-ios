//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit

/// Represents an item in the Actito inbox.
///
/// An ``ActitoInboxItem`` contains a notification and metadata about its read state
/// within the inbox. Inbox items can optionally have an expiration date.
public struct ActitoInboxItem: Codable, Equatable, Sendable {
    /// Unique identifier of the inbox item.
    public let id: String

    /// ``ActitoNotification` associated with this inbox item.
    public let notification: ActitoNotification

    /// Timestamp indicating when the item was received.
    public let time: Date

    /// Indicates whether the item has been opened by the user.
    public let opened: Bool

    /// Optional expiration timestamp of the item.
    public let expires: Date?

    /// Constructor for ``ActitoInboxItem``.
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
    /// Serializes ``ActitoInboxItem`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoInboxItem`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito inbox item.
    ///
    /// - Returns: A parsed ``ActitoInboxItem`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInboxItem.self, from: data)
    }
}

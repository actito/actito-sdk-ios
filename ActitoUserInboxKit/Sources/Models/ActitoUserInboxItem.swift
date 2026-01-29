//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

/// Represents an item in the Actito user inbox.
///
/// An ``ActitoUserInboxItem`` contains a notification and metadata about its read
/// state within the inbox. Inbox items can optionally have an expiration date.
public struct ActitoUserInboxItem: Codable, Equatable, Sendable {
    /// Unique identifier of the inbox item.
    public let id: String

    /// Notification associated with this inbox item.
    public let notification: ActitoNotification

    /// Timestamp indicating when the item was received.
    public let time: Date

    /// Indicates whether the item has been opened by the user.
    public let opened: Bool

    /// Optional expiration timestamp of the item.
    public let expires: Date?

    /// Constructor for ``ActitoUserInboxItem``.
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
    /// Serializes ``ActitoUserInboxItem`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoUserInboxItem`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito user inbox item.
    ///
    /// - Returns: A parsed ``ActitoUserInboxItem`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoUserInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoUserInboxItem.self, from: data)
    }
}

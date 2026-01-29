//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents a system-level notification sent by Actito.
///
/// An ``ActitoSystemNotification`` contains metadata about system events or updates,
/// distinct from user-targeted notifications. These notifications may include
/// additional information in the ``extra`` map.
public struct ActitoSystemNotification: Codable, Equatable, Sendable {
    /// Unique identifier of the system notification.
    public let id: String

    /// Type of the system notification.
    public let type: String

    /// Collection of key-value pairs used to add extra information to the notification.
    @ActitoExtraDictionary public private(set) var extra: [String: Any]

    /// Constructor for ``ActitoSystemNotification``.
    public init(id: String, type: String, extra: [String: Any]) {
        self.id = id
        self.type = type
        self.extra = extra
    }

    internal init(userInfo: [AnyHashable: Any]) {
        id = userInfo["id"] as! String
        type = userInfo["systemType"] as! String

        let stringKeyedUserInfo = userInfo.filter { $0.key is String } as! [String: Any]
        let ignoreKeys = ["aps", "system", "systemType", "attachment", "notificationId", "notificationType", "id"]

        extra = stringKeyedUserInfo.filter { !ignoreKeys.contains($0.key) && !$0.key.hasPrefix("x-") }
    }
}

// Identifiable: ActitoSystemNotification
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoSystemNotification: Identifiable {}

// JSON: ActitoSystemNotification
extension ActitoSystemNotification {
    /// Serializes ``ActitoSystemNotification`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoSystemNotification`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito system notification.
    ///
    /// - Returns: A parsed ``ActitoSystemNotification`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoSystemNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoSystemNotification.self, from: data)
    }
}

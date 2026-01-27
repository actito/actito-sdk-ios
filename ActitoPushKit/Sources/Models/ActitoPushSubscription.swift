//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

/// Represents a push notification subscription for a device.
///
/// An ``ActitoPushSubscription`` stores the push token that allows Actito to send
/// push notifications to the device.
public struct ActitoPushSubscription: Codable, Sendable {
    /// Device push token used to receive notifications.
    ///
    /// This may be null if the device has not yet registered for push notifications.
    public let token: String

    /// Constructor for ``ActitoPushSubscription``.
    public init(token: String) {
        self.token = token
    }
}

// JSON: ActitoPushSubscription
extension ActitoPushSubscription {
    /// Serializes ``ActitoPushSubscription`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoPushSubscription`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito push subscription.
    ///
    /// - Returns: A parsed ``ActitoPushSubscription`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoPushSubscription {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoPushSubscription.self, from: data)
    }
}

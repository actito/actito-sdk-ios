//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public typealias ActitoUserData = [String: String]

/// Represents a device registered in Actito.
///
/// An ``ActitoDevice`` is associated with a physical device and may be optionally linked to a user.
/// It contains timezone information, user-related metadata, and optional configuration such as do-not-disturb settings.
public struct ActitoDevice: Codable, Equatable, Sendable {
    /// Unique identifier of the device.
    public let id: String

    /// Optional identifier of the user associated with the device.
    public let userId: String?

    /// Optional display name of the associated user.
    public let userName: String?

    /// Time zone offset of the device in hours relative to UTC.
    public let timeZoneOffset: Float

    /// Optional ``ActitoDoNotDisturb``configuration for the device.
    public let dnd: ActitoDoNotDisturb?

    /// Custom user data associated with the device.
    ///
    /// This map contains key–value pairs representing user attributes or profile information linked to the device.
    public let userData: ActitoUserData

    /// Whether the device has background refresh enabled.
    public let backgroundAppRefresh: Bool

    /// Constructor for ``ActitoDevice``.
    public init(id: String, userId: String? = nil, userName: String? = nil, timeZoneOffset: Float, dnd: ActitoDoNotDisturb? = nil, userData: ActitoUserData, backgroundAppRefresh: Bool) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.timeZoneOffset = timeZoneOffset
        self.dnd = dnd
        self.userData = userData
        self.backgroundAppRefresh = backgroundAppRefresh
    }
}

// Identifiable: ActitoDevice
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoDevice: Identifiable {}

// JSON: ActitoDevice
extension ActitoDevice {
    /// Serializes ``ActitoDevice`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoDevice`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito Device.
    ///
    /// - Returns: A parsed ``ActitoDevice`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoDevice {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDevice.self, from: data)
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents an Actito application.
///
/// An ``ActitoApplication`` describes the capabilities, services, and configuration
/// of an application as defined in Actito. It includes enabled services, region
/// and inbox configuration, available user data fields, and supported action categories.
public struct ActitoApplication: Codable, Equatable, Sendable {
    /// Unique identifier of the application.
    public let id: String

    /// Name of the application.
    public let name: String

    /// Category of the application as defined in Actito.
    public let category: String

    /// The App Store ID of the application
    public let appStoreId: String?

    /// Map of enabled services for the application.
    public let services: [String: Bool]

    /// Optional inbox-related configuration.
    public let inboxConfig: InboxConfig?

    /// Optional region-related configuration.
    public let regionConfig: RegionConfig?

    /// List of user data fields supported by the application.
    public let userDataFields: [UserDataField]

    /// List of action categories available in the application.
    public let actionCategories: [ActionCategory]

    /// Indicates whether event payloads must respect a maximum size limit.
    public let enforceSizeLimit: Bool?

    /// Indicates whether tag names must comply with predefined restrictions.
    public let enforceTagRestrictions: Bool?

    /// Indicates whether event names must comply with predefined naming rules.
    public let enforceEventNameRestrictions: Bool?

    /// Constructor for ``ActitoApplication``.
    public init(id: String, name: String, category: String, appStoreId: String?, services: [String: Bool], inboxConfig: ActitoApplication.InboxConfig?, regionConfig: ActitoApplication.RegionConfig?, userDataFields: [ActitoApplication.UserDataField], actionCategories: [ActitoApplication.ActionCategory], enforceSizeLimit: Bool?, enforceTagRestrictions: Bool?, enforceEventNameRestrictions: Bool?) {
        self.id = id
        self.name = name
        self.category = category
        self.appStoreId = appStoreId
        self.services = services
        self.inboxConfig = inboxConfig
        self.regionConfig = regionConfig
        self.userDataFields = userDataFields
        self.actionCategories = actionCategories
        self.enforceSizeLimit = enforceSizeLimit
        self.enforceTagRestrictions = enforceTagRestrictions
        self.enforceEventNameRestrictions = enforceEventNameRestrictions
    }

    /// Keys representing services that can be enabled or disabled for an application.
    ///
    /// These values are used as keys in the `services` dictionary of ``ActitoApplication``.
    public enum ServiceKey: String {
        /// OAuth 2.0 authentication service.
        case oauth2

        /// Rich push notifications with extended content.
        case richPush

        /// Location-based services, including geofencing and beacons.
        case locationServices

        /// Apple Push Notification Service.
        case apns

        /// Google Cloud Messaging (Android).
        case gcm

        /// WebSocket-based real-time communication.
        case websockets

        /// Wallet functionality (passes, tickets, coupons).
        case passbook

        /// In-app purchase tracking and integration.
        case inAppPurchase

        /// Inbox and message storage.
        case inbox

        /// Remote file and asset storage.
        case storage
    }

    /// Configuration related to inbox-based features.
    public struct InboxConfig: Codable, Equatable, Sendable {

        /// Whether the inbox feature is enabled for the application.
        public let useInbox: Bool

        /// Whether the user inbox feature is enabled for the application.
        public let useUserInbox: Bool

        /// Whether inbox messages should automatically update the application badge count.
        public let autoBadge: Bool

        /// Constructor for ``InboxConfig``.
        public init(useInbox: Bool, useUserInbox: Bool, autoBadge: Bool) {
            self.useInbox = useInbox
            self.useUserInbox = useUserInbox
            self.autoBadge = autoBadge
        }
    }

    /// Configuration related to region-based features.
    public struct RegionConfig: Codable, Equatable, Sendable {
        /// Optional UUID used for beacon detection.
        public let proximityUUID: String?

        /// Constructor for ``RegionConfig``.
        public init(proximityUUID: String?) {
            self.proximityUUID = proximityUUID
        }
    }

    /// Describes a user data field supported by an Actito application.
    ///
    /// User data fields define the structure of user attributes that can be stored and leveraged for segmentation or personalization.
    public struct UserDataField: Codable, Equatable, Sendable {
        /// The data type of the field.
        public let type: String

        /// The unique key identifying the field.
        public let key: String

        /// Human-readable label for the field.
        public let label: String

        /// Constructor for ``UserDataField``.
        public init(type: String, key: String, label: String) {
            self.type = type
            self.key = key
            self.label = label
        }
    }

    /// Groups related actions that can be triggered from notifications or other engagement mechanisms.
    public struct ActionCategory: Codable, Equatable, Sendable {
        /// The name of the action category.
        public let name: String

        /// Optional description explaining the purpose of the category.
        public let description: String?

        /// The category type identifier.
        public let type: String

        /// List of actions belonging to this category.
        public let actions: [ActitoNotification.Action]

        /// Constructor for ``ActionCategory``.
        public init(name: String, description: String?, type: String, actions: [ActitoNotification.Action]) {
            self.name = name
            self.description = description
            self.type = type
            self.actions = actions
        }
    }
}

// Identifiable: ActitoApplication
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoApplication: Identifiable {}

// JSON: ActitoApplication
extension ActitoApplication {
    /// Serializes ``ActitoApplication`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoApplication`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito Application.
    ///
    /// - Returns: A parsed ``ActitoApplication`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoApplication {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoApplication.self, from: data)
    }
}

// JSON: ActitoApplication.InboxConfig
extension ActitoApplication.InboxConfig {
    /// Serializes ``InboxConfig`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates a ``InboxConfig`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Inbox Config.
    ///
    /// - Returns: A parsed ``InboxConfig`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoApplication.InboxConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoApplication.InboxConfig.self, from: data)
    }
}

// JSON: ActitoApplication.RegionConfig
extension ActitoApplication.RegionConfig {
    /// Serializes ``RegionConfig`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates a ``RegionConfig`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Region Config.
    ///
    /// - Returns: A parsed ``RegionConfig`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoApplication.RegionConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoApplication.RegionConfig.self, from: data)
    }
}

// JSON: ActitoApplication.UserDataField
extension ActitoApplication.UserDataField {
    /// Serializes ``UserDataField`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``UserDataField`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the User Data Field.
    ///
    /// - Returns: A parsed ``UserDataField`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoApplication.UserDataField {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoApplication.UserDataField.self, from: data)
    }
}

// JSON: ActitoApplication.ActionCategory
extension ActitoApplication.ActionCategory {
    /// Serializes ``ActionCategory`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActionCategory`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Action Category.
    ///
    /// - Returns: A parsed ``ActionCategory`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoApplication.ActionCategory {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoApplication.ActionCategory.self, from: data)
    }
}

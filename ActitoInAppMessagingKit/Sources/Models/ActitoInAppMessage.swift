//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents an in-app message delivered by Actito.
///
/// An ``ActitoInAppMessage`` defines content that can be displayed directly within
/// the application. Messages may include text, images, and actions for user interaction.
public struct ActitoInAppMessage: Codable, Equatable, Sendable {
    /// Unique identifier of the in-app message.
    public let id: String

    /// Human-readable name of the message.
    public let name: String

    /// Type of the message.
    public let type: String

    /// List of contexts where the message should be displayed.
    public let context: [String]

    /// Optional title of the message.
    public let title: String?

    /// Optional body text of the message.
    public let message: String?

    /// Optional portrait image URL associated with the message.
    public let image: String?

    /// Optional landscape image URL associated with the message.
    public let landscapeImage: String?

    /// Delay before displaying the message, in seconds.
    public let delaySeconds: Int

    /// Optional primary action associated with the message.
    public let primaryAction: Action?

    /// Optional secondary action associated with the message.
    public let secondaryAction: Action?

    /// Constructor for ``ActitoInAppMessage``.
    public init(id: String, name: String, type: String, context: [String], title: String?, message: String?, image: String?, landscapeImage: String?, delaySeconds: Int, primaryAction: ActitoInAppMessage.Action?, secondaryAction: ActitoInAppMessage.Action?) {
        self.id = id
        self.name = name
        self.type = type
        self.context = context
        self.title = title
        self.message = message
        self.image = image
        self.landscapeImage = landscapeImage
        self.delaySeconds = delaySeconds
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    /// Represents an action associated with an in-app message.
    ///
    /// An `Àction``defines a user interaction option for an in-app
    /// message, such as opening a URL or performing an operation.
    public struct Action: Codable, Equatable, Sendable {
        /// Optional label displayed for the action.
        public let label: String?

        /// Indicates whether the action is destructive.
        public let destructive: Bool

        /// Optional target URL triggered by the action.
        public let url: String?

        /// Constructor for ``Action``.
        public init(label: String?, destructive: Bool, url: String?) {
            self.label = label
            self.destructive = destructive
            self.url = url
        }
    }

    // Supported message types.
    public enum MessageType: String {
        /// In-app message displayed as a banner.
        case banner = "re.notifica.inappmessage.Banner"

        /// In-app message displayed as a card.
        case card = "re.notifica.inappmessage.Card"

        /// In-app message displayed in full screen.
        case fullscreen = "re.notifica.inappmessage.Fullscreen"
    }

    /// Supported contexts.
    public enum ContextType: String {
        /// Display in-app message when the app is launched.
        case launch

        /// Display in-app message when the app enters the foreground.
        case foreground
    }

    /// Supported Action types
    public enum ActionType: String {
        /// Primary action.
        case primary

        /// Secondary action.
        case secondary
    }
}

// Identifiable: ActitoInAppMessage
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoInAppMessage: Identifiable {}

// JSON: ActitoInAppMessage
extension ActitoInAppMessage {
    /// Serializes ``ActitoInAppMessage`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoInAppMessage`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito in-app message.
    ///
    /// - Returns: A parsed ``ActitoInAppMessage`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoInAppMessage {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInAppMessage.self, from: data)
    }
}

// JSON: ActitoInAppMessage.Action
extension ActitoInAppMessage.Action {
    /// Serializes ``Action`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Action`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the action.
    ///
    /// - Returns: A parsed ``Action`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoInAppMessage.Action {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInAppMessage.Action.self, from: data)
    }
}

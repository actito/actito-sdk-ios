//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

/// Represents a notification delivered by Actito.
///
/// An ``ActitoNotification`` contains the payload of a notification, including
/// its content, actions, attachments, and additional metadata.
/// Notifications may be partial, meaning that only a subset of fields is provided
/// and additional data may need to be fetched.
public struct ActitoNotification: Codable, Equatable, Sendable {
    /// Indicates whether this notification is partial.
    ///
    /// When `true`, the notification does not contain the full payload.
    public let partial: Bool

    /// Unique identifier of the notification.
    public let id: String

    /// Type of the notification.
    ///
    /// This value is defined by Actito and is used to distinguish different
    /// notification behaviors.
    public let type: String

    /// Timestamp indicating when the notification was generated.
    public let time: Date

    /// Optional title displayed in the notification.
    public let title: String?

    /// Optional subtitle displayed in the notification.
    public let subtitle: String?

    /// Main message body of the notification.
    public let message: String

    /// Structured content elements associated with the notification.
    public let content: [Content]

    /// List of actions that can be performed from the notification.
    public let actions: [Action]

    /// List of attachments included with the notification.
    public let attachments: [Attachment]

    /// Collection of key-value pairs used to add extra information to the notification.
    @ActitoExtraDictionary public private(set) var extra: [String: Any]

    /// Optional identifier of the target content related to the notification.
    public let targetContentIdentifier: String?

    /// Constructor for ``ActitoNotification``.
    public init(partial: Bool, id: String, type: String, time: Date, title: String?, subtitle: String?, message: String, content: [ActitoNotification.Content], actions: [ActitoNotification.Action], attachments: [ActitoNotification.Attachment], extra: [String: Any], targetContentIdentifier: String?) {
        self.partial = partial
        self.id = id
        self.type = type
        self.time = time
        self.title = title
        self.subtitle = subtitle
        self.message = message
        self.content = content
        self.actions = actions
        self.attachments = attachments
        self.extra = extra
        self.targetContentIdentifier = targetContentIdentifier
    }

    /// Supported Notification types.
    public enum NotificationType: String {
        /// Will only open the app without showing additional UI.
        case none = "re.notifica.notification.None"

        /// Displays a simple alert-style notification.
        case alert = "re.notifica.notification.Alert"

        /// Displays the OS built-in browser and loads a provided URL.
        case inAppBrowser = "re.notifica.notification.InAppBrowser"

        /// Displays a native web view and loads a provided HTML markup.
        case webView = "re.notifica.notification.WebView"

        /// Displays a native web view and loads a provided URL.
        case url = "re.notifica.notification.URL"

        /// Opens a URL or a custom URL scheme, automatically deciding how to display it.
        case urlResolver = "re.notifica.notification.URLResolver"

        /// Opens a URL using a custom URL scheme to drive users directly into a view on the app.
        case urlScheme = "re.notifica.notification.URLScheme"

        /// Displays an image gallery with provided images.
        case image = "re.notifica.notification.Image"

        /// Plays a Youtube, Vimeo or uploaded MP4 video.
        case video = "re.notifica.notification.Video"

        /// Displays a native map with provided location markers.
        case map = "re.notifica.notification.Map"

        /// Prompts the user to rate the application.
        case rate = "re.notifica.notification.Rate"

        /// Displays a Apple Wallet compatible card created on Actito.
        case passbook = "re.notifica.notification.Passbook"

        /// Opens an application store page.
        case store = "re.notifica.notification.Store"

        /// Displays a Apple Wallet compatible card created on Actito.
        case pass = "re.notifica.notification.Pass"

        /// Displays a Qualifio campaign via the Qualifio SDK, if available.
        case qualifio = "re.notifica.notification.qualifio.Campaign"
    }

    /// Represents a structured content element within a notification.
    public struct Content: Codable, Equatable, Sendable {
        /// The content type identifier. These types include:
        public let type: String

        /// The content payload.
        @ActitoAnyValue public private(set) var data: Any

        /// Constructor for ``Content``.
        public init(type: String, data: Any) {
            self.type = type
            self.data = data
        }
    }

    /// Represents an action that can be triggered from a notification.
    public struct Action: Codable, Equatable, Sendable {
        /// Type of the action.
        public let type: String

        /// User-visible label of the action.
        public let label: String

        /// Optional target associated with the action.
        public let target: String?

        /// Whether the action requires keyboard input.
        public let keyboard: Bool

        /// Whether the action requires camera access.
        public let camera: Bool

        /// Whether the action is destructive.
        public let destructive: Bool?

        /// Optional platform-specific icon configuration for the action.
        public let icon: Icon?

        /// Constructor for ``Action``.
        public init(type: String, label: String, target: String?, keyboard: Bool, camera: Bool, destructive: Bool?, icon: ActitoNotification.Action.Icon?) {
            self.type = type
            self.label = label
            self.target = target
            self.keyboard = keyboard
            self.camera = camera
            self.destructive = destructive
            self.icon = icon
        }

        public enum ActionType: String {
            /// Uses deep links to open the application to a specific screen or triggers a deep link in another app that supports the provided URI.
            case app = "re.notifica.action.App"

            /// Opens the target URL in the system’s default web browser.
            case browser = "re.notifica.action.Browser"

            /// Action that collects a response from the user.
            ///
            /// This action can capture a simple confirmation, text input via the keyboard, or media input using the device camera, depending on its configuration.
            case callback = "re.notifica.action.Callback"

            /// Executes custom behavior in the application.
            ///
            /// This action requires additional client-side implementation to handle the associated payload.
            case custom = "re.notifica.action.Custom"

            /// Opens the device’s default email application with a prefilled recipient.
            case mail = "re.notifica.action.Mail"

            /// Opens the device’s default SMS application with a prefilled recipient.
            case sms = "re.notifica.action.SMS"

            /// Opens the default Telephone application to phone call a provided phone number.
            case telephone = "re.notifica.action.Telephone"

            /// Opens the target URL inside an in-app browser.
            case inAppBrowser = "re.notifica.action.InAppBrowser"

            @available(*, deprecated, message: "The WebView action type becomes a backwards compatible alias. Use the InAppBrowser action type instead.", renamed: "inAppBrowser")
            case webView = "re.notifica.action.WebView"
        }

        /// Defines platform-specific icons for a notification action.
        public struct Icon: Codable, Equatable, Sendable {
            /// Resource identifier for Android.
            public let android: String?

            /// Resource identifier for iOS.
            public let ios: String?

            /// Resource identifier for Web.
            public let web: String?

            /// Constructor for ``Icon``.
            public init(android: String?, ios: String?, web: String?) {
                self.android = android
                self.ios = ios
                self.web = web
            }
        }
    }

    /// Represents an attachment included with a notification.
    public struct Attachment: Codable, Equatable, Sendable {
        /// MIME type of the attachment.
        public let mimeType: String

        /// URI pointing to the attachment resource.
        public let uri: String

        /// Constructor for ``Attachment``.
        public init(mimeType: String, uri: String) {
            self.mimeType = mimeType
            self.uri = uri
        }
    }
}

// Identifiable: ActitoNotification
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoNotification: Identifiable {}

// JSON: ActitoNotification
extension ActitoNotification {
    /// Serializes ``ActitoNotification`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoNotification`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito notification.
    ///
    /// - Returns: A parsed ``ActitoNotification`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.self, from: data)
    }
}

// JSON: ActitoNotification.Content
extension ActitoNotification.Content {
    /// Serializes ``Content`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Content`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the content.
    ///
    /// - Returns: A parsed ``Content`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Content {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Content.self, from: data)
    }
}

// JSON: ActitoNotification.Action
extension ActitoNotification.Action {
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
    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Action {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Action.self, from: data)
    }
}

// JSON: ActitoNotification.Action.Icon
extension ActitoNotification.Action.Icon {
    /// Serializes ``Icon`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Icon`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the icon.
    ///
    /// - Returns: A parsed ``Icon`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Action.Icon {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Action.Icon.self, from: data)
    }
}

// JSON: ActitoNotification.Attachment
extension ActitoNotification.Attachment {
    /// Serializes ``Attachment`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``Attachment`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the attachment.
    ///
    /// - Returns: A parsed ``Attachment`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Attachment {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Attachment.self, from: data)
    }
}

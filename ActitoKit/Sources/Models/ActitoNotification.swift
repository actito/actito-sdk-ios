//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public struct ActitoNotification: Codable, Equatable, Sendable {
    public let partial: Bool
    public let id: String
    public let type: String
    public let time: Date
    public let title: String?
    public let subtitle: String?
    public let message: String
    public let content: [Content]
    public let actions: [Action]
    public let attachments: [Attachment]
    @ActitoExtraEquatable public private(set) var extra: [String: Any]
    public let targetContentIdentifier: String?

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

    public enum NotificationType: String {
        case none = "re.notifica.notification.None"
        case alert = "re.notifica.notification.Alert"
        case inAppBrowser = "re.notifica.notification.InAppBrowser"
        case webView = "re.notifica.notification.WebView"
        case url = "re.notifica.notification.URL"
        case urlResolver = "re.notifica.notification.URLResolver"
        case urlScheme = "re.notifica.notification.URLScheme"
        case image = "re.notifica.notification.Image"
        case video = "re.notifica.notification.Video"
        case map = "re.notifica.notification.Map"
        case rate = "re.notifica.notification.Rate"
        case passbook = "re.notifica.notification.Passbook"
        case store = "re.notifica.notification.Store"
    }

    public struct Content: Codable, Equatable, Sendable {
        public let type: String
        @ActitoExtraEquatable public private(set) var data: Any

        public init(type: String, data: Any) {
            self.type = type
            self.data = data
        }
    }

    public struct Action: Codable, Equatable, Sendable {
        public let type: String
        public let label: String
        public let target: String?
        public let keyboard: Bool
        public let camera: Bool
        public let destructive: Bool?
        public let icon: Icon?

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
            case app = "re.notifica.action.App"
            case browser = "re.notifica.action.Browser"
            case callback = "re.notifica.action.Callback"
            case custom = "re.notifica.action.Custom"
            case mail = "re.notifica.action.Mail"
            case sms = "re.notifica.action.SMS"
            case telephone = "re.notifica.action.Telephone"
            case inAppBrowser = "re.notifica.action.InAppBrowser"

            @available(*, deprecated, message: "The WebView action type becomes a backwards compatible alias. Use the InAppBrowser action type instead.", renamed: "inAppBrowser")
            case webView = "re.notifica.action.WebView"
        }

        public struct Icon: Codable, Equatable, Sendable {
            public let android: String?
            public let ios: String?
            public let web: String?

            public init(android: String?, ios: String?, web: String?) {
                self.android = android
                self.ios = ios
                self.web = web
            }
        }
    }

    public struct Attachment: Codable, Equatable, Sendable {
        public let mimeType: String
        public let uri: String

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
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.self, from: data)
    }
}

// Codable: ActitoNotification
extension ActitoNotification {
    internal enum CodingKeys: String, CodingKey {
        case partial
        case id
        case type
        case time
        case title
        case subtitle
        case message
        case content
        case actions
        case attachments
        case extra
        case targetContentIdentifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        partial = try container.decodeIfPresent(Bool.self, forKey: .partial) ?? false
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        time = try container.decode(Date.self, forKey: .time)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        message = try container.decode(String.self, forKey: .message)
        content = try container.decode([Content].self, forKey: .content)
        actions = try container.decode([Action].self, forKey: .actions)
        attachments = try container.decode([Attachment].self, forKey: .attachments)

        let decodedExtra = try container.decode(ActitoAnyCodable.self, forKey: .extra)
        extra = decodedExtra.value as! [String: Any]

        targetContentIdentifier = try container.decodeIfPresent(String.self, forKey: .targetContentIdentifier)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(partial, forKey: .partial)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(time, forKey: .time)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(message, forKey: .message)
        try container.encode(content, forKey: .content)
        try container.encode(actions, forKey: .actions)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(ActitoAnyCodable(extra), forKey: .extra)
        try container.encode(targetContentIdentifier, forKey: .targetContentIdentifier)
    }
}

// JSON: ActitoNotification.Content
extension ActitoNotification.Content {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Content {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Content.self, from: data)
    }
}

// Codable: ActitoNotification.Content
extension ActitoNotification.Content {
    internal enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        let decoded = try container.decode(ActitoAnyCodable.self, forKey: .data)
        data = decoded.value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(ActitoAnyCodable(data), forKey: .data)
    }
}

// JSON: ActitoNotification.Action
extension ActitoNotification.Action {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Action {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Action.self, from: data)
    }
}

// JSON: ActitoNotification.Action.Icon
extension ActitoNotification.Action.Icon {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Action.Icon {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Action.Icon.self, from: data)
    }
}

// JSON: ActitoNotification.Attachment
extension ActitoNotification.Attachment {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoNotification.Attachment {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoNotification.Attachment.self, from: data)
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public struct ActitoInAppMessage: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let type: String
    public let context: [String]
    public let title: String?
    public let message: String?
    public let image: String?
    public let landscapeImage: String?
    public let delaySeconds: Int
    public let primaryAction: Action?
    public let secondaryAction: Action?

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

    public struct Action: Codable, Equatable, Sendable {
        public let label: String?
        public let destructive: Bool
        public let url: String?

        public init(label: String?, destructive: Bool, url: String?) {
            self.label = label
            self.destructive = destructive
            self.url = url
        }
    }

    public enum MessageType: String {
        case banner = "re.notifica.inappmessage.Banner"
        case card = "re.notifica.inappmessage.Card"
        case fullscreen = "re.notifica.inappmessage.Fullscreen"
    }

    public enum ContextType: String {
        case launch
        case foreground
    }

    public enum ActionType: String {
        case primary
        case secondary
    }
}

// Identifiable: ActitoInAppMessage
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoInAppMessage: Identifiable {}

// JSON: ActitoInAppMessage
extension ActitoInAppMessage {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoInAppMessage {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInAppMessage.self, from: data)
    }
}

// JSON: ActitoInAppMessage.Action
extension ActitoInAppMessage.Action {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoInAppMessage.Action {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoInAppMessage.Action.self, from: data)
    }
}

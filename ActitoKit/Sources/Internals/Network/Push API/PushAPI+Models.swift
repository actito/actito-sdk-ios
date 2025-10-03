//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

extension ActitoInternals.PushAPI.Models {
    public struct Application: Decodable, Equatable, Sendable {
        public let _id: String
        public let name: String
        public let category: String
        public let appStoreId: String?
        public let services: [String: Bool]
        public let inboxConfig: ActitoApplication.InboxConfig?
        public let regionConfig: ActitoApplication.RegionConfig?
        public let userDataFields: [ActitoApplication.UserDataField]
        public let actionCategories: [ActionCategory]
        public let enforceSizeLimit: Bool

        public struct ActionCategory: Decodable, Equatable, Sendable {
            public let name: String
            public let description: String?
            public let type: String
            public let actions: [Notification.Action]
        }

        public func toModel() -> ActitoApplication {
            ActitoApplication(
                id: _id,
                name: name,
                category: category,
                appStoreId: appStoreId,
                services: services,
                inboxConfig: inboxConfig,
                regionConfig: regionConfig,
                userDataFields: userDataFields,
                actionCategories: actionCategories.map { category in
                    ActitoApplication.ActionCategory(
                        name: category.name,
                        description: category.description,
                        type: category.type,
                        actions: category.actions.compactMap { $0.toModel() }
                    )
                },
                enforceSizeLimit: enforceSizeLimit,
            )
        }
    }

    public struct Notification: Equatable, Sendable {
        public let _id: String
        public let type: String
        public let time: Date
        public let title: String?
        public let subtitle: String?
        public let message: String
        public let content: [ActitoNotification.Content]
        public let actions: [Action]
        public let attachments: [ActitoNotification.Attachment]
        @ActitoExtraEquatable public private(set) var extra: [String: Any]
        public let targetContentIdentifier: String?

        public struct Action: Decodable, Equatable, Sendable {
            public let type: String
            public let label: String?
            public let target: String?
            public let keyboard: Bool?
            public let camera: Bool?
            public let destructive: Bool?
            public let icon: ActitoNotification.Action.Icon?

            public func toModel() -> ActitoNotification.Action? {
                guard let label = label else { return nil }

                return ActitoNotification.Action(
                    type: type,
                    label: label,
                    target: target,
                    keyboard: keyboard ?? false,
                    camera: camera ?? false,
                    destructive: destructive,
                    icon: icon
                )
            }
        }

        public func toModel() -> ActitoNotification {
            ActitoNotification(
                partial: false,
                id: _id,
                type: type,
                time: time,
                title: title,
                subtitle: subtitle,
                message: message,
                content: content,
                actions: actions.compactMap { $0.toModel() },
                attachments: attachments,
                extra: extra.compactMapValues { $0 is NSNull ? nil : $0 },
                targetContentIdentifier: targetContentIdentifier
            )
        }
    }
}

extension ActitoInternals.PushAPI.Models.Notification: Decodable {
    internal enum CodingKeys: String, CodingKey {
        case _id
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

        _id = try container.decode(String.self, forKey: ._id)
        type = try container.decode(String.self, forKey: .type)
        time = try container.decode(Date.self, forKey: .time)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        message = try container.decode(String.self, forKey: .message)

        if container.contains(.content) {
            content = try container.decode([ActitoNotification.Content].self, forKey: .content)
        } else {
            content = []
        }

        if container.contains(.actions) {
            actions = try container.decode([Action].self, forKey: .actions)
        } else {
            actions = []
        }

        if container.contains(.attachments) {
            attachments = try container.decode([ActitoNotification.Attachment].self, forKey: .attachments)
        } else {
            attachments = []
        }

        if container.contains(.extra) {
            let decoded = try container.decode(ActitoAnyCodable.self, forKey: .extra)
            extra = (decoded.value as! [String: Any]).compactMapValues { $0 is NSNull ? nil : $0 }
        } else {
            extra = [:]
        }

        targetContentIdentifier = try container.decodeIfPresent(String.self, forKey: .targetContentIdentifier)
    }
}

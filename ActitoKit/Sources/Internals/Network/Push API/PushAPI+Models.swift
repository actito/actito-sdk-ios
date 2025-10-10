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
        public let enforceTagRestrictions: Bool?
        public let enforceEventNameRestrictions: Bool?

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
                enforceTagRestrictions: enforceTagRestrictions,
                enforceEventNameRestrictions: enforceEventNameRestrictions,
            )
        }
    }

    public struct Notification: Decodable, Equatable, Sendable {
        public let _id: String
        public let type: String
        public let time: Date
        public let title: String?
        public let subtitle: String?
        public let message: String
        public let content: [ActitoNotification.Content]?
        public let actions: [Action]?
        public let attachments: [ActitoNotification.Attachment]?
        @ActitoExtraDictionary public private(set) var extra: [String: Any]?
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
                content: content ?? [],
                actions: actions?.compactMap { $0.toModel() } ?? [],
                attachments: attachments ?? [],
                extra: extra ?? [:],
                targetContentIdentifier: targetContentIdentifier
            )
        }
    }
}

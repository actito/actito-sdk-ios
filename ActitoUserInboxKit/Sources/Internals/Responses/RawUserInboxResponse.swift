//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

internal struct RawUserInboxResponse: Decodable, Equatable {
    internal let count: Int
    internal let unread: Int
    internal let inboxItems: [RawUserInboxItem]

    internal struct RawUserInboxItem: Decodable, Equatable {
        internal let _id: String
        internal let notification: String
        internal let type: String
        internal let time: Date
        internal let title: String?
        internal let subtitle: String?
        internal let message: String
        internal let attachment: ActitoNotification.Attachment?
        @ActitoExtraDictionary internal private(set) var extra: [String: Any]?
        internal let opened: Bool?
        internal let expires: Date?

        internal func toModel() -> ActitoUserInboxItem {
            ActitoUserInboxItem(
                id: _id,
                notification: ActitoNotification(
                    partial: true,
                    id: notification,
                    type: type,
                    time: time,
                    title: title,
                    subtitle: subtitle,
                    message: message,
                    content: [],
                    actions: [],
                    attachments: attachment.map { [$0] } ?? [],
                    extra: extra ?? [:],
                    targetContentIdentifier: nil
                ),
                time: time,
                opened: opened ?? false,
                expires: expires
            )
        }
    }
}

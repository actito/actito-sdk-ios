//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit

extension ActitoInternals.PushAPI.Models {
    internal struct RemoteInboxItem: Decodable, Equatable, Sendable {
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
        internal let visible: Bool?
        internal let expires: Date?

        internal func toLocal() -> LocalInboxItem {
            LocalInboxItem(
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
                visible: visible ?? true,
                expires: expires
            )
        }
    }
}

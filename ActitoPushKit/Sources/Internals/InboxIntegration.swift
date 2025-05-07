//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit

internal class InboxIntegration {
    private static let addInboxItemNotification = NSNotification.Name(rawValue: "ActitoInboxKit.AddInboxItem")
    private static let readInboxItemNotification = NSNotification.Name(rawValue: "ActitoInboxKit.ReadInboxItem")
    private static let refreshBadgeNotification = NSNotification.Name(rawValue: "ActitoInboxKit.RefreshBadge")
    private static let reloadInboxNotification = NSNotification.Name(rawValue: "ActitoInboxKit.ReloadInbox")

    private init() {}

    internal static func reloadInbox() {
        NotificationCenter.default.post(
            name: reloadInboxNotification,
            object: nil,
            userInfo: nil
        )
    }

    internal static func refreshBadge() {
        NotificationCenter.default.post(
            name: refreshBadgeNotification,
            object: nil,
            userInfo: nil
        )
    }

    internal static func addItemToInbox(userInfo: [AnyHashable: Any], notification: ActitoNotification) {
        guard let inboxItemId = userInfo["inboxItemId"] as? String else {
            logger.debug("Received a notification payload without an inbox item id. Inbox functionality disabled.")
            return
        }

        var content: [String: Any] = [
            "notification": notification,
            "inboxItemId": inboxItemId,
            "inboxItemVisible": userInfo["inboxItemVisible"] as? Bool ?? false,
        ]

        if let expiresMillis = userInfo["inboxItemExpires"] as? Double {
            content["inboxItemExpires"] = Date(timeIntervalSince1970: expiresMillis / 1000)
        }

        // Notify the inbox to add this item.
        NotificationCenter.default.post(
            name: addInboxItemNotification,
            object: nil,
            userInfo: content
        )
    }

    internal static func markItemAsRead(userInfo: [AnyHashable: Any]) {
        guard let inboxItemId = userInfo["inboxItemId"] as? String else {
            logger.debug("Received a notification payload without an inbox item id. Inbox functionality disabled.")
            return
        }

        NotificationCenter.default.post(
            name: readInboxItemNotification,
            object: nil,
            userInfo: [
                "inboxItemId": inboxItemId,
            ]
        )
    }
}

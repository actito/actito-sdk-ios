//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import CoreData

extension InboxItemEntity {
    internal convenience init(from item: LocalInboxItem, context: NSManagedObjectContext) throws {
        let encoder = JSONEncoder.actito

        self.init(context: context)
        id = item.id
        notificationId = item.notification.id

        do {
            notification = try encoder.encode(item.notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        time = item.time
        opened = item.opened
        visible = item.visible
        expires = item.expires
    }

    internal func setNotification(_ notification: ActitoNotification) throws {
        let encoder = JSONEncoder.actito

        do {
            self.notification = try encoder.encode(notification)
            self.notificationId = notification.id
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }
    }

    internal func toLocal() throws -> LocalInboxItem {
        let decoder = JSONDecoder.actito

        guard let id = id else {
            throw InboxDatabaseError.invalidArgument("id", cause: nil)
        }

        guard let notificationData = notification else {
            throw InboxDatabaseError.invalidArgument("notification", cause: nil)
        }

        let notification: ActitoNotification

        do {
            notification = try decoder.decode(ActitoNotification.self, from: notificationData)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        guard let time = time else {
            throw InboxDatabaseError.invalidArgument("time", cause: nil)
        }

        return LocalInboxItem(
            id: id,
            notification: notification,
            time: time,
            opened: opened,
            visible: visible,
            expires: expires
        )
    }
}

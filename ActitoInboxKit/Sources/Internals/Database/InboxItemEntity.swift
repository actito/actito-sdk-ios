//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import CoreData

extension InboxItemEntity {
    internal var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }

    internal convenience init(from model: ActitoInboxItem, visible: Bool, context: NSManagedObjectContext) throws {
        let encoder = JSONEncoder.actito

        self.init(context: context)
        id = model.id
        notificationId = model.notification.id

        do {
            notification = try encoder.encode(model.notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        time = model.time
        opened = model.opened
        self.visible = visible
        expires = model.expires
    }

    internal func setNotification(_ notification: ActitoNotification) throws {
        let encoder = JSONEncoder.actito

        do {
            self.notification = try encoder.encode(notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }
    }

    internal func toModel() throws -> ActitoInboxItem {
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

        return ActitoInboxItem(
            id: id,
            notification: notification,
            time: time,
            opened: opened,
            expires: expires
        )
    }
}

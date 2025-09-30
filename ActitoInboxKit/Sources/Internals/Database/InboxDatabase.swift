//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import CoreData
import Foundation

@ActitoDatabaseActor
internal final class InboxDatabase {
    private nonisolated let name = "NotificareInboxDatabase"
    private let database: ActitoVersionedDatabase

    internal nonisolated init(overrideDatabaseFileProtection: Bool) {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: name, withExtension: ".momd")
        else {
            logger.error("Failed to get \(name) path.")
            fatalError("Failed to get \(name) path.")
        }

        database = ActitoVersionedDatabase(
            name: name,
            path: path,
            rebuildOnVersionChange: true,
            mergePolicy: .overwrite,
            sdkVersion: Actito.SDK_VERSION,
            shouldOverrideDatabaseFileProtection: overrideDatabaseFileProtection
        )
    }

    internal func find() async throws -> [LocalInboxItem] {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        return try await context.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")

            // NOTE: Make sure the cached items are always sorted by date descending.
            // The most recent one is important to be the first as the sync logic relies on it.
            request.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(InboxItemEntity.time), ascending: false),
            ]

            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                do {
                    return try entity.toLocal()
                } catch {
                    logger.warning("Unable to decode inbox item '\(entity.id ?? "")' from the database.", error: error)
                    return nil
                }
            }
        }
    }

    @discardableResult
    internal func add(_ item: LocalInboxItem) async throws -> NSManagedObjectID {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        let objectID = try await context.performCompat {
            let entity = try InboxItemEntity(from: item, context: context)
            return entity.objectID
        }

        await database.saveChanges()

        return objectID
    }

    internal func update(_ item: LocalInboxItem) async throws {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        try await context.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "id = %@", item.id)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                return
            }

            try entity.setNotification(item.notification)
            entity.opened = item.opened
        }

        await database.saveChanges()
    }

    internal func remove(id: String) async throws {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        try await context.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "id = %@", id)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try context.execute(deleteRequest)
        }

        await database.saveChanges()
    }

    internal func remove(notificationId: String) async throws {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        try await context.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "notificationId = %@", notificationId)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try context.execute(deleteRequest)
        }

        await database.saveChanges()
    }

    internal func clear() async throws {
        await database.ensureLoadedStores()

        let context = database.backgroundContext
        let persistentContainer = database.persistentContainer

        try await context.performCompat {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        }
    }
}

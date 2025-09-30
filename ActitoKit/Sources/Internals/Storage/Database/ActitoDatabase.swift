//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import CoreData
import Foundation

@ActitoDatabaseActor
internal final class ActitoDatabase {
    private nonisolated let name = "NotificareDatabase"
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
            sdkVersion: Actito.SDK_VERSION,
            shouldOverrideDatabaseFileProtection: overrideDatabaseFileProtection
        )
    }

    internal func fetchEvents() async throws -> [LocalEvent] {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        return try await context.performCompat {
            let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
            let events = try context.fetch(request)
            return events.compactMap { event in
                do {
                    return try event.toLocal()
                } catch {
                    logger.warning("Unable to decode event '\(event.type ?? "")' from the database.", error: error)
                    return nil
                }
            }
        }
    }

    @discardableResult
    internal func add(_ event: LocalEvent) async throws -> NSManagedObjectID {
        await database.ensureLoadedStores()

        let context = database.backgroundContext

        let objectID = try await context.performCompat {
            let entity = try NotificareCoreDataEvent(from: event, context: context)
            return entity.objectID
        }

        await database.saveChanges()

        return objectID
    }

    internal func update(_ event: LocalEvent) async throws {
        await database.ensureLoadedStores()

        guard let id = event.objectID else {
            return
        }

        let context = database.backgroundContext

        try await context.performCompat {
            let entity = try context.existingObject(with: id) as! NotificareCoreDataEvent
            entity.retries = event.retries
        }

        await database.saveChanges()
    }

    internal func remove(_ event: LocalEvent) async {
        await database.ensureLoadedStores()

        guard let id = event.objectID else {
            return
        }

        let context = database.backgroundContext

        await context.performCompat {
            let entity: NSManagedObject

            do {
                entity = try context.existingObject(with: id)
            } catch {
                // The event for the given was removed in the meantime.
                return
            }

            guard !entity.isDeleted else {
                return
            }

            context.delete(entity)
        }

        await database.saveChanges()
    }

    internal func clearEvents() async throws {
        await database.ensureLoadedStores()

        let context = database.backgroundContext
        let persistentContainer = database.persistentContainer

        try await context.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificareCoreDataEvent")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        }

        await database.saveChanges()
    }

    internal func clear() async throws {
        try await clearEvents()
    }
}

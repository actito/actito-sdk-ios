//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import CoreData
import Foundation

internal class InboxDatabase: ActitoAbstractDatabase {
    internal init() {
        super.init(
            name: "NotificareInboxDatabase",
            rebuildOnVersionChange: true,
            mergePolicy: .overwrite
        )
    }

    internal func add(_ item: ActitoInboxItem, visible: Bool) async throws -> InboxItemEntity {
        ensureLoadedStores()

        let entity = try await backgroundContext.performCompat {
            try InboxItemEntity(from: item, visible: visible, context: self.backgroundContext)
        }

        await saveChanges()

        return entity
    }

    internal func find() async throws -> [InboxItemEntity] {
        ensureLoadedStores()

        return try await backgroundContext.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
            return try self.backgroundContext.fetch(request)
        }
    }

    internal func find(id: String) async throws -> [InboxItemEntity] {
        ensureLoadedStores()

        return try await backgroundContext.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "id = %@", id)

            return try self.backgroundContext.fetch(request)
        }
    }

    internal func remove(_ item: InboxItemEntity) async {
        ensureLoadedStores()

        await backgroundContext.performCompat {
            let entity = self.backgroundContext.object(with: item.objectID)
            self.backgroundContext.delete(entity)
        }

        await saveChanges()
    }

    internal func clear() async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: self.backgroundContext)
        }
    }
}

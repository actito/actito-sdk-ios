//
// Copyright (c) 2025 Actito. All rights reserved.
//

import CoreData
import Foundation

@ActitoDatabaseActor
public final class ActitoVersionedDatabase {
    private let name: String
    private let path: URL
    private let rebuildOnVersionChange: Bool
    private let mergePolicy: ActitoDatabaseMergePolicy?
    private let version: String
    private let shouldOverrideDatabaseFileProtection: Bool

    private var isLoaded = false
    private var loadTask: Task<Void, Never>?

    private var databaseVersionKey: String {
        "re.notifica.database_version.\(name)"
    }

    private nonisolated var databaseUrl: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("\(name).sqlite")
    }

    public lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let model = NSManagedObjectModel(contentsOf: path)
        else {
            logger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        let container = NSPersistentContainer(name: name, managedObjectModel: model)

        if shouldOverrideDatabaseFileProtection {
            let storeDescription = NSPersistentStoreDescription(url: databaseUrl)
            storeDescription.type = NSSQLiteStoreType
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.setOption(FileProtectionType.none as NSObject, forKey: NSPersistentStoreFileProtectionKey)

            container.persistentStoreDescriptions = [storeDescription]
        }

        return container
    }()

    public lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()

    private var hasLoadedPersistentStores: Bool {
        !persistentContainer.persistentStoreCoordinator.persistentStores.isEmpty
    }

    public nonisolated init(
        name: String,
        path: URL,
        rebuildOnVersionChange: Bool,
        mergePolicy: ActitoDatabaseMergePolicy? = nil,
        version: String,
        shouldOverrideDatabaseFileProtection: Bool
    ) {
        self.name = name
        self.path = path
        self.rebuildOnVersionChange = rebuildOnVersionChange
        self.mergePolicy = mergePolicy
        self.version = version
        self.shouldOverrideDatabaseFileProtection = shouldOverrideDatabaseFileProtection
    }

    public func ensureLoadedStores() async {
        guard !isLoaded else { return }

        if let loadTask {
            await loadTask.value
            return
        }

        let task = Task {
            // Force the container to be loaded.
            _ = persistentContainer

            if let currentVersion = UserDefaults.standard.string(forKey: databaseVersionKey), currentVersion != version {
                logger.debug("Database version mismatch. Recreating...")
                removeStore()
            }

            logger.debug("Loading database: \(name)")
            await loadStore()

            if let mergePolicy {
                backgroundContext.mergePolicy = mergePolicy.policy
            }

            isLoaded = true
        }

        loadTask = task

        await task.value
    }

    public func saveChanges() async {
        let context = self.backgroundContext
        let hasLoadedPersistentStores = self.hasLoadedPersistentStores

        await context.performCompat {
            guard context.hasChanges else {
                return
            }

            guard hasLoadedPersistentStores else {
                logger.warning("Cannot save the database changes before the persistent stores are loaded.")
                return
            }

            do {
                try context.save()
            } catch {
                logger.error("Failed to persist changes to CoreData.", error: error)
            }
        }
    }

    private func loadStore() async {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores

        if !stores.isEmpty {
            logger.debug("Reloading CoreData stores for '\(self.name)'.")

            for store in stores {
                do {
                    try persistentContainer.persistentStoreCoordinator.remove(store)
                } catch {
                    logger.error("Failed to reload store.", error: error)
                    return
                }
            }
        }

        await withCheckedContinuation { continuation in
            persistentContainer.loadPersistentStores { _, error in
                if let error {
                    logger.error("Failed to load CoreData store '\(self.name)'.", error: error)
                } else {
                    // Update the database version in local storage.
                    UserDefaults.standard.set(self.version, forKey: self.databaseVersionKey)
                }

                continuation.resume()
            }
        }
    }

    private func removeStore() {
        guard FileManager.default.fileExists(atPath: databaseUrl.path) else {
            logger.debug("Database file not found.")
            return
        }

        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: databaseUrl, ofType: "sqlite")
            logger.debug("Database removed.")
        } catch {
            logger.debug("Failed to remove database.")
        }
    }
}

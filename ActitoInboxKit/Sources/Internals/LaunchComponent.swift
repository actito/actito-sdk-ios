//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        Actito.shared.inboxImplementation().database.configure()

        Task {
            await Actito.shared.inboxImplementation().loadCache()
        }

        // Listen to inbox addition requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inboxImplementation(),
            selector: #selector(Actito.shared.inboxImplementation().onAddItemNotification(_:)),
            name: ActitoInboxImpl.addInboxItemNotification,
            object: nil
        )

        // Listen to inbox read requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inboxImplementation(),
            selector: #selector(Actito.shared.inboxImplementation().onReadItemNotification(_:)),
            name: ActitoInboxImpl.readInboxItemNotification,
            object: nil
        )

        // Listen to badge refresh requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inboxImplementation(),
            selector: #selector(Actito.shared.inboxImplementation().onRefreshBadgeNotification(_:)),
            name: ActitoInboxImpl.refreshBadgeNotification,
            object: nil
        )

        // Listen to inbox reload requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inboxImplementation(),
            selector: #selector(Actito.shared.inboxImplementation().onReloadInboxNotification(_:)),
            name: ActitoInboxImpl.reloadInboxNotification,
            object: nil
        )

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inboxImplementation(),
            selector: #selector(Actito.shared.inboxImplementation().onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        try await Actito.shared.inboxImplementation().database.clear()
        LocalStorage.clear()
    }

    internal func launch() async throws {
        Actito.shared.inboxImplementation().sync()
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        try await Actito.shared.inboxImplementation().clearLocalInbox()
        Actito.shared.inboxImplementation().clearNotificationCenter()

        try await Actito.shared.inboxImplementation().clearRemoteInbox()

        Actito.shared.inboxImplementation().notifyItemsUpdated(Actito.shared.inboxImplementation().items)
        _ = try? await Actito.shared.inboxImplementation().refreshBadge()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

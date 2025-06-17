//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal let implementation = ActitoInboxImpl.instance

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        implementation.database.configure()

        Task {
            await implementation.loadCachedItems()
        }

        // Listen to inbox addition requests.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onAddItemNotification(_:)),
            name: ActitoInboxImpl.addInboxItemNotification,
            object: nil
        )

        // Listen to inbox read requests.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onReadItemNotification(_:)),
            name: ActitoInboxImpl.readInboxItemNotification,
            object: nil
        )

        // Listen to badge refresh requests.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onRefreshBadgeNotification(_:)),
            name: ActitoInboxImpl.refreshBadgeNotification,
            object: nil
        )

        // Listen to inbox reload requests.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onReloadInboxNotification(_:)),
            name: ActitoInboxImpl.reloadInboxNotification,
            object: nil
        )

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            implementation,
            selector: #selector(implementation.onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        try await implementation.database.clear()
        LocalStorage.clear()
    }

    internal func launch() async throws {
        implementation.sync()
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        try await implementation.clearLocalInbox()
        implementation.clearNotificationCenter()

        try await implementation.clearRemoteInbox()

        implementation.notifyItemsUpdated(implementation.items)
        _ = try? await implementation.refreshBadge()
    }

    internal func executeCommand(_ command: String, data: Any?) async throws -> Any? {
        return nil
    }
}

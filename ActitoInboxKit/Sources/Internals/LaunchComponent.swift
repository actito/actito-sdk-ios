//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

internal final class LaunchComponent: NSObject, ActitoLaunchComponent {
    internal static let instance = LaunchComponent()

    internal func migrate() {
        // no-op
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Actito.shared.options?.debugLoggingEnabled ?? false

        Actito.shared.inbox().database.configure(overrideDatabaseFileProtection: Actito.shared.options?.overrideDatabaseFileProtection ?? false)

        Task {
            await Actito.shared.inbox().loadCachedItems()
        }

        // Listen to inbox addition requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inbox(),
            selector: #selector(Actito.shared.inbox().onAddItemNotification(_:)),
            name: ActitoInbox.addInboxItemNotification,
            object: nil
        )

        // Listen to inbox read requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inbox(),
            selector: #selector(Actito.shared.inbox().onReadItemNotification(_:)),
            name: ActitoInbox.readInboxItemNotification,
            object: nil
        )

        // Listen to badge refresh requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inbox(),
            selector: #selector(Actito.shared.inbox().onRefreshBadgeNotification(_:)),
            name: ActitoInbox.refreshBadgeNotification,
            object: nil
        )

        // Listen to inbox reload requests.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inbox(),
            selector: #selector(Actito.shared.inbox().onReloadInboxNotification(_:)),
            name: ActitoInbox.reloadInboxNotification,
            object: nil
        )

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            Actito.shared.inbox(),
            selector: #selector(Actito.shared.inbox().onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        try await Actito.shared.inbox().database.clear()
        LocalStorage.clear()
    }

    internal func launch() async throws {
        Actito.shared.inbox().sync()
    }

    internal func postLaunch() async throws {
        // no-op
    }

    internal func unlaunch() async throws {
        try await Actito.shared.inbox().clearLocalInbox()
        Actito.shared.inbox().clearNotificationCenter()

        try await Actito.shared.inbox().clearRemoteInbox()

        Actito.shared.inbox().notifyItemsUpdated(Actito.shared.inbox().items)
        _ = try? await Actito.shared.inbox().refreshBadge()
    }

    internal func executeCommand(_ command: String, data: Any?) throws -> (any Sendable)? {
        return nil
    }
}

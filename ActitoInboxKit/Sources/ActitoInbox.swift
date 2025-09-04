//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Combine
import UIKit

public class ActitoInbox {
    public static let shared = ActitoInbox()

    internal static let addInboxItemNotification = NSNotification.Name(rawValue: "ActitoInboxKit.AddInboxItem")
    internal static let readInboxItemNotification = NSNotification.Name(rawValue: "ActitoInboxKit.ReadInboxItem")
    internal static let refreshBadgeNotification = NSNotification.Name(rawValue: "ActitoInboxKit.RefreshBadge")
    internal static let reloadInboxNotification = NSNotification.Name(rawValue: "ActitoInboxKit.ReloadInbox")

    internal let database = InboxDatabase()
    private let cache = InboxCache()
    private var cachedItems: [LocalInboxItem] = []

    private var _badgeStream = CurrentValueSubject<Int, Never>(0)
    private var _itemsStream = CurrentValueSubject<[ActitoInboxItem], Never>([])

    internal init() {
        itemsStream = _itemsStream
            .map { items in
                items.filter { !$0.isExpired }
            }
            .eraseToAnyPublisher()

        badgeStream = _badgeStream.eraseToAnyPublisher()
    }

    // MARK: - Public API

    /// Specifies the delegate that handles inbox events
    ///
    /// This property allows setting a delegate conforming to ``ActitoInboxDelegate`` to respond to various inbox events, such as
    /// inbox and badges updates.
    public weak var delegate: ActitoInboxDelegate?

    /// A list of all ``ActitoInboxItem``, sorted by timestamp.
    public var items: [ActitoInboxItem] {
        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            return []
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Actito inbox functionality is not enabled.")
            return []
        }

        return cachedItems.compactMap { item in
            guard item.visible && !item.isExpired else {
                return nil
            }

            return ActitoInboxItem(
                id: item.id,
                notification: item.notification,
                time: item.time,
                opened: item.opened,
                expires: item.expires
            )
        }
    }

    /// A Publisher for observing changes to inbox items, suitable for real-time UI updates to reflect inbox state changes.
    public let itemsStream: AnyPublisher<[ActitoInboxItem], Never>

    /// The current badge count, representing the number of unread inbox items.
    public var badge: Int {
        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            return 0
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Actito inbox functionality is not enabled.")
            return 0
        }

        guard application.inboxConfig?.autoBadge == true else {
            logger.warning("Actito auto badge functionality is not enabled.")
            return 0
        }

        return LocalStorage.currentBadge
    }

    /// A Publisher for observing changes to the badge count, providing real-time updates when the unread count changes.
    public let badgeStream: AnyPublisher<Int, Never>

    /// Refreshes the inbox data, ensuring the items and badge count reflect the latest server state, with a callback.
    ///
    ///  - Parameters:
    ///     - completion: A callback that will be invoked with the result of the refresh inbox operation.
    public func refresh(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await refresh()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Refreshes the inbox data, ensuring the items and badge count reflect the latest server state.
    public func refresh() async throws {
        try checkPrerequisites()

        try await reloadInbox()
    }

    /// Refreshes the current badge count to match the number of unread inbox items, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the badge refresh operation
    public func refreshBadge(_ completion: @escaping ActitoCallback<Int>) {
        Task {
            do {
                let result = try await refreshBadge()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Refreshes the current badge count to match the number of unread inbox items.
    ///
    /// - Returns: The updated number of unread messages.
    @discardableResult
    public func refreshBadge() async throws -> Int {
        try checkPrerequisites()

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        guard Actito.shared.application?.inboxConfig?.autoBadge == true else {
            logger.warning("Actito auto badge functionality is not enabled.")
            throw ActitoInboxError.autoBadgeUnavailable
        }

        do {
            let response = try await fetchRemoteInbox(for: device.id, skip: 0, limit: 1)

            // Keep a cached copy of the current badge.
            LocalStorage.currentBadge = response.unread

            // Update the application badge.
            await setApplicationBadge(response.unread)

            notifyBadgeUpdated(response.unread)

            return response.unread
        } catch {
            logger.error("Failed to refresh the badge.", error: error)
            throw error
        }
    }

    /// Opens a specified inbox item, marking it as read and returning the associated notification, with a callback.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to open.
    ///   - completion: A callback that will be invoked with the result ot the notification open operation.
    public func open(_ item: ActitoInboxItem, _ completion: @escaping ActitoCallback<ActitoNotification>) {
        Task {
            do {
                let result = try await open(item)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Opens a specified inbox item, marking it as read and returning the associated notification.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to open.
    ///
    /// - Returns: The ``ActitoNotification`` associated with the inbox item.
    public func open(_ item: ActitoInboxItem) async throws -> ActitoNotification {
        try checkPrerequisites()

        if item.notification.partial {
            let notification = try await Actito.shared.fetchNotification(item.id)

            if let localItem = await cache.update(item, { $0.notification = notification}) {
                await updateLocalItems()

                do {
                    try await self.database.update(localItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
                }
            }

            // Mark the item as read & send a notification open event.
            try await markAsRead(item)
            return notification
        } else {
            // Mark the item as read & send a notification open event.
            try await markAsRead(item)
            return item.notification
        }
    }

    /// Marks the specified inbox item as read, with a callback.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to mark as read.
    ///   - completion: A callback that will be invoked with the result of the mark as read operation.
    public func markAsRead(_ item: ActitoInboxItem, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await markAsRead(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Marks the specified inbox item as read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to mark as read.
    public func markAsRead(_ item: ActitoInboxItem) async throws {
        try checkPrerequisites()

        do {
            // Send an event to mark the notification as read in the remote inbox.
            try await Actito.shared.events().logNotificationOpen(item.notification.id)

            // Update the cache.
            if let updatedItem = await cache.update(item, { $0.opened = true}) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
                }
            }

            // No need to keep the item in the notification center.
            Actito.shared.removeNotificationFromNotificationCenter(item.notification)

            notifyItemsUpdated(self.items)
            _ = try? await refreshBadge()
        } catch {
            logger.warning("Failed to mark item as read.", error: error)
            throw error
        }
    }

    /// Marks all inbox items as read, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the mark all as read operation.
    public func markAllAsRead(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await markAllAsRead()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Marks all inbox items as read.
    public func markAllAsRead() async throws {
        try checkPrerequisites()

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        try await ActitoRequest.Builder()
            .put("/notification/inbox/fordevice/\(device.id)")
            .response()

        // Skip items where nothing changes.
        for item in await cache.items.filter({ !$0.opened && $0.visible}) {
            // Update the cache.
            if let updatedItem = await cache.update(item, { $0.opened = true}) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
                }
            }
        }

        // Clear all items from the notification center.
        clearNotificationCenter()

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
    }

    /// Permanently removes the specified inbox item from the inbox, with a callback.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to remove.
    ///   - completion: A callback that will be invoked with the result of the remove operation.
    public func remove(_ item: ActitoInboxItem, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await remove(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Permanently removes the specified inbox item from the inbox.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoInboxItem`` to remove.
    public func remove(_ item: ActitoInboxItem) async throws {
        try checkPrerequisites()

        try await ActitoRequest.Builder()
            .delete("/notification/inbox/\(item.id)")
            .response()

        try await database.remove(id: item.id)
        await cache.removeAll(id: item.id)
        await updateLocalItems()

        Actito.shared.removeNotificationFromNotificationCenter(item.notification)

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
    }

    /// Clears all inbox items, permanently deleting them from the inbox., with a callback
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the clear operation.
    public func clear(_ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await clear()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Clears all inbox items, permanently deleting them from the inbox.
    public func clear() async throws {
        try checkPrerequisites()

        try await clearRemoteInbox()

        try await clearLocalInbox()
        clearNotificationCenter()

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
    }

    // MARK: - Internal API

    internal func notifyItemsUpdated(_ items: [ActitoInboxItem]) {
        DispatchQueue.main.async {
            self.delegate?.actito(self, didUpdateInbox: self.items)
        }

        _itemsStream.value = items
    }

    private func notifyBadgeUpdated(_ badge: Int) {
        DispatchQueue.main.async {
            self.delegate?.actito(self, didUpdateBadge: badge)
        }

        _badgeStream.value = badge
    }

    private func checkPrerequisites() throws {
        guard Actito.shared.isReady else {
            logger.warning("Actito is not ready yet.")
            throw ActitoError.notReady
        }

        guard let application = Actito.shared.application else {
            logger.warning("Actito application is not yet available.")
            throw ActitoError.applicationUnavailable
        }

        guard application.services[ActitoApplication.ServiceKey.inbox.rawValue] == true else {
            logger.warning("Actito inbox functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Actito inbox functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.inbox.rawValue)
        }
    }

    internal func sync() {
        guard let device = Actito.shared.device().currentDevice else {
            logger.warning("No device registered yet. Skipping...")
            return
        }

        Task {
            guard let firstItem = await cache.items.first else {
                logger.debug("The local inbox contains no items. Checking remotely.")
                do {
                    try await reloadInbox()
                } catch {
                    logger.error("Failed to reload the inbox.", error: error)
                }

                return
            }

            do {
                let timestamp = Int64(firstItem.time.timeIntervalSince1970 * 1000)
                logger.debug("Checking if the inbox has been modified since \(timestamp).")

                _ = try await fetchRemoteInbox(for: device.id, since: timestamp)

                logger.info("The inbox has been modified. Performing a full sync.")
                do {
                    try await reloadInbox()
                } catch {
                    logger.error("Failed to reload the inbox.", error: error)
                }
            } catch {
                if case let ActitoNetworkError.validationError(response, _, _) = error {
                    if response.statusCode == 304 {
                        logger.debug("The inbox has not been modified. Proceeding with locally stored data.")

                        _ = try? await refreshBadge()
                        notifyItemsUpdated(self.items)

                        return
                    }
                }

                logger.error("Failed to fetch the remote inbox.", error: error)
            }
        }
    }

    private func reloadInbox() async throws {
        try await clearLocalInbox()
        try await requestRemoteInboxItems()
    }

    internal func loadCache() async {
        do {
            let items = try await database.find()
            await cache.set(items)
            await updateLocalItems()
        } catch {
            logger.error("Failed to query the local database.", error: error)
        }
    }

    private func addToLocalInbox(_ item: LocalInboxItem) async throws {
        // NOTE: Remove duplicates for a given notification before adding the item to the inbox.
        // When receiving a triggered notification, we may receive it more than once.
        await cache.removeAll(notificationId: item.notification.id)
        try await database.remove(notificationId: item.notification.id)

        do {
            try await database.add(item)
            await cache.add(item)
        } catch {
            logger.warning("Unable to encode inbox item '\(item.id)' into the database.", error: error)
        }

        await updateLocalItems()
    }

    internal func clearLocalInbox() async throws {
        try await database.clear()
        await cache.removeAll()
        await updateLocalItems()
    }

    private func removeExpiredItemsFromNotificationCenter() async {
        await cache.items.forEach { item in
            if item.isExpired {
                Actito.shared.removeNotificationFromNotificationCenter(item.notification.id)
            }
        }
    }

    internal func clearNotificationCenter() {
        logger.debug("Removing all messages from the notification center.")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func fetchRemoteInbox(for deviceId: String, since: Int64? = nil, skip: Int = 0, limit: Int = 100) async throws -> ActitoInternals.PushAPI.Responses.RemoteInbox {
        let request = ActitoRequest.Builder()
            .get("/notification/inbox/fordevice/\(deviceId)")
            .query(name: "skip", value: String(format: "%d", skip))
            .query(name: "limit", value: String(format: "%d", limit))

        if let since = since {
            _ = request.query(name: "ifModifiedSince", value: "\(since)")
        }

        return try await request.responseDecodable(ActitoInternals.PushAPI.Responses.RemoteInbox.self)
    }

    // TODO: Refactor out recursion.
    private func requestRemoteInboxItems(step: Int = 0) async throws {
        guard let device = Actito.shared.device().currentDevice else {
            logger.warning("Actito has not been configured yet.")
            throw ActitoError.deviceUnavailable
        }

        let response = try await fetchRemoteInbox(for: device.id, skip: step * 100, limit: 100)

        // Add all items to the database.
        for item in response.inboxItems {
            try await addToLocalInbox(item.toLocal())
        }

        if response.count > (step + 1) * 100 {
            logger.debug("Loading more inbox items.")
            try await requestRemoteInboxItems(step: step + 1)
        } else {
            logger.debug("Done loading inbox items.")

            notifyItemsUpdated(self.items)
            _ = try? await self.refreshBadge()
        }
    }

    internal func clearRemoteInbox() async throws {
        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        try await ActitoRequest.Builder()
            .delete("/notification/inbox/fordevice/\(device.id)")
            .response()
    }

    private func updateLocalItems() async {
        cachedItems = await cache.items
    }

    @MainActor
    private func setApplicationBadge(_ badge: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badge
    }

    // MARK: - NotificationCenter events

    @objc internal func onAddItemNotification(_ notificationSignal: Notification) {
        logger.debug("Received a signal to add an item to the inbox.")

        guard let userInfo = notificationSignal.userInfo,
              let notification = userInfo["notification"] as? ActitoNotification,
              let inboxItemId = userInfo["inboxItemId"] as? String,
              let inboxItemVisible = userInfo["inboxItemVisible"] as? Bool
        else {
            logger.warning("Unable to handle 'add to inbox' signal.")
            return
        }

        Task {
            do {
                try await addToLocalInbox(
                    LocalInboxItem(
                        id: inboxItemId,
                        notification: notification,
                        time: Date(),
                        opened: false,
                        visible: inboxItemVisible,
                        expires: userInfo["inboxItemExpires"] as? Date
                    )
                )
            } catch {
                logger.warning("Unable to add inbox item to local cache.", error: error)
            }

            _ = try? await refreshBadge()
            notifyItemsUpdated(self.items)
        }
    }

    @objc internal func onReadItemNotification(_ notification: Notification) {
        logger.debug("Received a signal to mark an item as read.")

        guard let userInfo = notification.userInfo, let inboxItemId = userInfo["inboxItemId"] as? String else {
            logger.warning("Unable to handle the notification read request.")
            return
        }

        Task {
            // Update the cache.
            if let updatedItem = await cache.update(inboxItemId, { $0.opened = true }) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(inboxItemId)' into the database.", error: error)
                }
            }

            _ = try? await refreshBadge()
            notifyItemsUpdated(self.items)
        }
    }

    @objc internal func onRefreshBadgeNotification(_: Notification) {
        logger.debug("Received a signal to refresh the badge.")

        Task {
            try? await refreshBadge()
        }
    }

    @objc internal func onReloadInboxNotification(_: Notification) {
        logger.debug("Received a signal to reload the inbox.")
        Task {
            do {
                try await reloadInbox()
            } catch {
                logger.error("Failed to reload the inbox.", error: error)
            }
        }
    }

    @objc internal func onApplicationDidBecomeActiveNotification(_: Notification) {
        // Don't check anything unless we're ready.
        guard Actito.shared.isReady else {
            return
        }

        // Wait a bit before checking.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                // Clear expired items from the notification center.
                await self.removeExpiredItemsFromNotificationCenter()

                guard let device = Actito.shared.device().currentDevice else {
                    logger.warning("Actito has not been configured yet.")
                    return
                }

                guard await !self.cache.items.isEmpty else {
                    logger.debug("The inbox is empty. No need to do a full sync.")
                    return
                }

                do {
                    let response = try await self.fetchRemoteInbox(for: device.id, skip: 0, limit: 1)

                    let total = self.items.count
                    let unread = self.items.filter { !$0.opened }.count

                    if response.count != total || response.unread != unread {
                        logger.debug("The inbox needs an update. The count/unread don't match with the local data.")
                        do {
                            try await self.reloadInbox()
                        } catch {
                            logger.error("Failed to reload the inbox.", error: error)
                        }
                    } else {
                        logger.debug("The inbox doesn't need an update. Proceeding as is.")
                    }
                } catch {
                    logger.error("Failed to compare the local and remote unread counts.", error: error)
                }
            }
        }
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

public class ActitoUserInbox {
    public static let shared = ActitoUserInbox()

    // MARK: - Public API

    /// Parses a JSON string to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a raw JSON string and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - string: The JSON string representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided JSON string.
    public func parseResponse(string: String) throws -> ActitoUserInboxResponse {
        guard let data = string.data(using: .utf8) else {
            throw ActitoUserInboxError.dataCorrupted
        }

        return try parseResponse(data: data)
    }

    /// Parses a dictionary to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a dictionary and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - json: The dictionary representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided string.
    public func parseResponse(json: [String: Any]) throws -> ActitoUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try parseResponse(data: data)
    }

    /// Parses a ``Data`` object to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a ``Data`` object and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - data: The ``Data`` object representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided ``Data`` object.
    public func parseResponse(data: Data) throws -> ActitoUserInboxResponse {
        try JSONDecoder.actito.decode(ActitoUserInboxResponse.self, from: data)
    }

    /// Opens a specified inbox item and retrieves its associated notification, with a callback.
    ///
    /// This is a suspending function that opens the provided ``ActitoUserInboxItem`` and returns the
    /// associated ``ActitoNotification`` via callback. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to open.
    ///   - completion: A callback that will be invoked with the result ot the notification open operation.
    public func open(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<ActitoNotification>) {
        Task {
            do {
                let result = try await open(item)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Opens a specified inbox item and retrieves its associated notification.
    ///
    /// This is a suspending function that opens the provided ``ActitoUserInboxItem`` and returns the
    /// associated ``ActitoNotification``. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to open.
    ///
    /// - Returns: The ``ActitoNotification`` associated with the opened inbox item.
    public func open(_ item: ActitoUserInboxItem) async throws -> ActitoNotification {
        try checkPrerequisites()

        let notification = try await fetchUserInboxNotification(item)

        // Mark the item as read & send a notification open event.
        try await markAsRead(item)
        return notification
    }

    /// Marks an inbox item as read, with a callback.
    ///
    /// This function updates the status of the provided ``ActitoUserInboxItem`` to read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to mark as read.
    ///   - completion: A callback that will be inboked with the result of the mark as read operation.
    public func markAsRead(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await markAsRead(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Marks an inbox item as read.
    ///
    /// This function updates the status of the provided ``ActitoUserInboxItem`` to read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to mark as read.
    public func markAsRead(_ item: ActitoUserInboxItem) async throws {
        try checkPrerequisites()

        try await Actito.shared.events().logNotificationOpen(item.notification.id)

        Actito.shared.removeNotificationFromNotificationCenter(item.notification)
    }

    /// Removes an inbox item from the user's inbox, with a callback.
    ///
    /// This method deletes the provided ``ActitoUserInboxItem`` from the user's inbox.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to be removed.
    ///   - completion: A callback that will be invoked with the result of the remove operation.
    public func remove(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<Void>) {
        Task {
            do {
                try await remove(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Removes an inbox item from the user's inbox.
    ///
    /// This method deletes the provided ``ActitoUserInboxItem`` from the user's inbox.
    ///
    /// - Parameter item: The ``ActitoUserInboxItem`` to be removed.
    public func remove(_ item: ActitoUserInboxItem) async throws {
        try checkPrerequisites()

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.deviceUnavailable
        }

        try await ActitoRequest.Builder()
            .delete("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .response()

        Actito.shared.removeNotificationFromNotificationCenter(item.notification)
    }

    // MARK: - Private API

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

        guard application.inboxConfig?.useUserInbox == true else {
            logger.warning("Actito user inbox functionality is not enabled.")
            throw ActitoError.serviceUnavailable(service: ActitoApplication.ServiceKey.inbox.rawValue)
        }
    }

    private func fetchUserInboxNotification(_ item: ActitoUserInboxItem) async throws -> ActitoNotification {
        guard Actito.shared.isConfigured else {
            throw ActitoError.notConfigured
        }

        guard let device = Actito.shared.device().currentDevice else {
            throw ActitoError.notConfigured
        }

        let response = try await ActitoRequest.Builder()
            .get("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .responseDecodable(ActitoInternals.PushAPI.Responses.UserInboxNotification.self)

        return response.notification.toModel()
    }
}

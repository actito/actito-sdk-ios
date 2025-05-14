//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import Foundation

public protocol ActitoUserInbox: AnyObject {
    /// Parses a JSON string to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a raw JSON string and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - string: The JSON string representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided JSON string.
    func parseResponse(string: String) throws -> ActitoUserInboxResponse

    /// Parses a dictionary to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a dictionary and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - json: The dictionary representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided string.
    func parseResponse(json: [String: Any]) throws -> ActitoUserInboxResponse

    /// Parses a ``Data`` object to produce a ``ActitoUserInboxResponse``.
    ///
    /// This method takes a ``Data`` object and converts it into a structured ``ActitoUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - data: The ``Data`` object representing the user inbox response.
    ///
    /// - Returns: A ``ActitoUserInboxResponse`` object parsed from the provided ``Data`` object.
    func parseResponse(data: Data) throws -> ActitoUserInboxResponse

    /// Opens a specified inbox item and retrieves its associated notification, with a callback.
    ///
    /// This is a suspending function that opens the provided ``ActitoUserInboxItem`` and returns the
    /// associated ``ActitoNotification`` via callback. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to open.
    ///   - completion: A callback that will be invoked with the result ot the notification open operation.
    func open(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<ActitoNotification>)

    /// Opens a specified inbox item and retrieves its associated notification.
    ///
    /// This is a suspending function that opens the provided ``ActitoUserInboxItem`` and returns the
    /// associated ``ActitoNotification``. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to open.
    ///
    /// - Returns: The ``ActitoNotification`` associated with the opened inbox item.
    func open(_ item: ActitoUserInboxItem) async throws -> ActitoNotification

    /// Marks an inbox item as read, with a callback.
    ///
    /// This function updates the status of the provided ``ActitoUserInboxItem`` to read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to mark as read.
    ///   - completion: A callback that will be inboked with the result of the mark as read operation.
    func markAsRead(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<Void>)

    /// Marks an inbox item as read.
    ///
    /// This function updates the status of the provided ``ActitoUserInboxItem`` to read.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to mark as read.
    func markAsRead(_ item: ActitoUserInboxItem) async throws

    /// Removes an inbox item from the user's inbox, with a callback.
    ///
    /// This method deletes the provided ``ActitoUserInboxItem`` from the user's inbox.
    ///
    /// - Parameters:
    ///   - item: The ``ActitoUserInboxItem`` to be removed.
    ///   - completion: A callback that will be invoked with the result of the remove operation.
    func remove(_ item: ActitoUserInboxItem, _ completion: @escaping ActitoCallback<Void>)

    /// Removes an inbox item from the user's inbox.
    ///
    /// This method deletes the provided ``ActitoUserInboxItem`` from the user's inbox.
    ///
    /// - Parameter item: The ``ActitoUserInboxItem`` to be removed.
    func remove(_ item: ActitoUserInboxItem) async throws
}

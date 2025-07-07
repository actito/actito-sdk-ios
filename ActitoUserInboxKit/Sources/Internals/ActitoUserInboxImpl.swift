//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import ActitoUtilitiesKit
import Foundation

internal class ActitoUserInboxImpl: ActitoUserInbox {
    internal static let instance = ActitoUserInboxImpl()

    // MARK: - Actito user inbox

    public func parseResponse(string: String) throws -> ActitoUserInboxResponse {
        guard let data = string.data(using: .utf8) else {
            throw ActitoUserInboxError.dataCorrupted
        }

        return try parseResponse(data: data)
    }

    public func parseResponse(json: [String: Any]) throws -> ActitoUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try parseResponse(data: data)
    }

    public func parseResponse(data: Data) throws -> ActitoUserInboxResponse {
        try JSONDecoder.actito.decode(ActitoUserInboxResponse.self, from: data)
    }

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

    public func open(_ item: ActitoUserInboxItem) async throws -> ActitoNotification {
        try checkPrerequisites()

        let notification = try await fetchUserInboxNotification(item)

        // Mark the item as read & send a notification open event.
        try await markAsRead(item)
        return notification
    }

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

    public func markAsRead(_ item: ActitoUserInboxItem) async throws {
        try checkPrerequisites()

        try await Actito.shared.events().logNotificationOpen(item.notification.id)

        Actito.shared.removeNotificationFromNotificationCenter(item.notification)
    }

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

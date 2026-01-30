//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

/// Represents the response returned when fetching a user's inbox.
///
/// An ``ActitoUserInboxResponse`` contains the total number of inbox items, the
/// number of unread items, and the list of items themselves.
public struct ActitoUserInboxResponse: Codable, Equatable, Sendable {
    /// Total number of items in the user's inbox.
    public let count: Int

    /// Number of unread items in the user's inbox.
    public let unread: Int

    /// List of inbox items for the user.
    public let items: [ActitoUserInboxItem]

    /// Constructor for ``ActitoUserInboxResponse``.
    public init(count: Int, unread: Int, items: [ActitoUserInboxItem]) {
        self.count = count
        self.unread = unread
        self.items = items
    }
}

// Codable: ActitoUserInboxResponse
extension ActitoUserInboxResponse {
    /// Decodable conformance for ``ActitoUserInboxResponse``
    public init(from decoder: Decoder) throws {
        do {
            let raw = try RawUserInboxResponse(from: decoder)

            count = raw.count
            unread = raw.unread
            items = raw.inboxItems.map { $0.toModel() }

            return
        } catch {
            logger.debug("Unable to parse user inbox response from the raw format.", error: error)
        }

        do {
            let consumer = try ConsumerUserInboxResponse(from: decoder)

            count = consumer.count
            unread = consumer.unread
            items = consumer.items
        } catch {
            logger.debug("Unable to parse user inbox response from the consumer format.", error: error)
            throw error
        }
    }

    /// Encodable conformance for ``ActitoUserInboxResponse``
    public func encode(to encoder: Encoder) throws {
        let consumer = ConsumerUserInboxResponse(count: count, unread: unread, items: items)
        try consumer.encode(to: encoder)
    }
}

// JSON: ActitoUserInboxResponse
extension ActitoUserInboxResponse {
    /// Serializes ``ActitoUserInboxResponse`` into a JSON object.
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    /// Creates an ``ActitoUserInboxResponse`` instance from a JSON object.
    ///
    /// - Parameters:
    ///   - json: The JSON representation of the Actito user inbox response
    ///
    /// - Returns: A parsed ``ActitoPushSubscription`` instance.
    public static func fromJson(json: [String: Any]) throws -> ActitoUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoUserInboxResponse.self, from: data)
    }
}

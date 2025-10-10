//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public struct ActitoSystemNotification: Codable, Equatable, Sendable {
    public let id: String
    public let type: String
    @ActitoExtraDictionary public private(set) var extra: [String: Any]

    public init(id: String, type: String, extra: [String: Any]) {
        self.id = id
        self.type = type
        self.extra = extra
    }

    internal init(userInfo: [AnyHashable: Any]) {
        id = userInfo["id"] as! String
        type = userInfo["systemType"] as! String

        let stringKeyedUserInfo = userInfo.filter { $0.key is String } as! [String: Any]
        let ignoreKeys = ["aps", "system", "systemType", "attachment", "notificationId", "notificationType", "id"]

        extra = stringKeyedUserInfo.filter { !ignoreKeys.contains($0.key) && !$0.key.hasPrefix("x-") }
    }
}

// Identifiable: ActitoSystemNotification
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoSystemNotification: Identifiable {}

// JSON: ActitoSystemNotification
extension ActitoSystemNotification {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoSystemNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoSystemNotification.self, from: data)
    }
}

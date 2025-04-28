//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit

public typealias ActitoUserData = [String: String]

public struct ActitoDevice: Codable, Equatable {
    public let id: String
    public let userId: String?
    public let userName: String?
    public let timeZoneOffset: Float
    public let dnd: ActitoDoNotDisturb?
    public let userData: ActitoUserData
    public let backgroundAppRefresh: Bool

    public init(id: String, userId: String? = nil, userName: String? = nil, timeZoneOffset: Float, dnd: ActitoDoNotDisturb? = nil, userData: ActitoUserData, backgroundAppRefresh: Bool) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.timeZoneOffset = timeZoneOffset
        self.dnd = dnd
        self.userData = userData
        self.backgroundAppRefresh = backgroundAppRefresh
    }
}

// Identifiable: ActitoDevice
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ActitoDevice: Identifiable {}

// JSON: ActitoDevice
extension ActitoDevice {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.actito.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> ActitoDevice {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.actito.decode(ActitoDevice.self, from: data)
    }
}

//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoUtilitiesKit
import Foundation

extension ActitoInternals.PushAPI.Payloads {
    internal struct CreateDevice: Encodable {
        internal var language: String
        internal var region: String
        internal var platform: String
        internal var osVersion: String
        internal var sdkVersion: String
        internal var appVersion: String
        internal var deviceString: String
        internal var timeZoneOffset: Float
        internal var backgroundAppRefresh: Bool
    }

    internal struct UpdateDevice: Encodable {
        internal var language: String
        internal var region: String
        internal var platform: String
        internal var osVersion: String
        internal var sdkVersion: String
        internal var appVersion: String
        internal var deviceString: String
        internal var timeZoneOffset: Float
        internal var backgroundAppRefresh: Bool
    }

    internal struct UpdateDeviceUser: Encodable {
        @EncodeNull internal var userID: String?
        @EncodeNull internal var userName: String?
    }

    internal struct UpdateDeviceDoNotDisturb: Encodable {
        @EncodeNull internal var dnd: ActitoDoNotDisturb?
    }

    internal struct UpdateDeviceUserData: Encodable {
        internal let userData: [String: String?]
    }

    internal struct UpgradeToLongLivedDevice: Encodable {
        internal let deviceID: String
        internal let transport: String
        internal let subscriptionId: String?
        internal let language: String
        internal let region: String
        internal let platform: String
        internal let osVersion: String
        internal let sdkVersion: String
        internal let appVersion: String
        internal let deviceString: String
        internal let timeZoneOffset: Float
        internal let backgroundAppRefresh: Bool
    }

    internal enum Device {
        internal struct UpdateTimeZone: Encodable {
            internal let language: String
            internal let region: String
            internal let timeZoneOffset: Float
        }

        internal struct UpdateLanguage: Encodable {
            internal let language: String
            internal let region: String
        }

        internal struct UpdateBackgroundAppRefresh: Encodable {
            internal let language: String
            internal let region: String
            internal let backgroundAppRefresh: Bool
        }

        internal struct Tags: Encodable {
            internal let tags: [String]
        }
    }

    internal struct CreateNotificationReply: Encodable {
        internal let notification: String
        internal let deviceID: String
        internal let userID: String?
        internal let label: String
        internal let data: ReplyData

        internal struct ReplyData: Encodable {
            internal let target: String?
            internal let message: String?
            internal let media: String?
            internal let mimeType: String?
        }
    }

    internal struct TestDeviceRegistration: Encodable {
        internal let deviceID: String
    }

    internal struct CreateEventPayload: Codable {
        internal let type: String
        internal let timestamp: Int64
        internal let deviceId: String
        internal let sessionId: String?
        internal let notificationId: String?
        internal let userId: String?
        internal private(set) var data: ActitoEventData?

        internal enum CodingKeys: String, CodingKey {
            case type
            case timestamp
            case deviceId = "deviceID"
            case sessionId = "sessionID"
            case notificationId = "notification"
            case userId = "userID"
            case data
        }

        internal init(
            type: String,
            timestamp: Int64,
            deviceId: String,
            sessionId: String? = nil,
            notificationId: String? = nil,
            userId: String? = nil,
            data: ActitoEventData? = nil
        ) {
            self.type = type
            self.timestamp = timestamp
            self.deviceId = deviceId
            self.sessionId = sessionId
            self.notificationId = notificationId
            self.userId = userId
            self.data = data
        }

        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            type = try container.decode(String.self, forKey: .type)
            timestamp = try container.decode(Int64.self, forKey: .timestamp)
            deviceId = try container.decode(String.self, forKey: .deviceId)
            sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
            notificationId = try container.decodeIfPresent(String.self, forKey: .notificationId)
            userId = try container.decodeIfPresent(String.self, forKey: .userId)

            if let data = try container.decodeIfPresent(ActitoAnyCodable.self, forKey: .data) {
                self.data = data.value as? ActitoEventData
            } else {
                data = nil
            }
        }

        internal func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(type, forKey: .type)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(deviceId, forKey: .deviceId)
            try container.encodeIfPresent(sessionId, forKey: .sessionId)
            try container.encodeIfPresent(notificationId, forKey: .notificationId)
            try container.encodeIfPresent(userId, forKey: .userId)

            if let data = data {
                try container.encode(ActitoAnyCodable(data), forKey: .data)
            }
        }
    }
}
